;; Consumer Protection Contract
;; Manages warranties, returns, and consumer protection compliance

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u300))
(define-constant ERR-INVALID-WARRANTY (err u301))
(define-constant ERR-WARRANTY-EXPIRED (err u302))
(define-constant ERR-INVALID-INPUT (err u303))
(define-constant ERR-CLAIM-NOT-FOUND (err u304))
(define-constant ERR-ALREADY-PROCESSED (err u305))

;; Data Variables
(define-data-var min-warranty-days uint u30) ;; Minimum 30 days warranty
(define-data-var max-return-days uint u14) ;; 14 days return policy

;; Data Maps
(define-map device-warranties
  {
    dealer: principal,
    device-id: (string-ascii 50)
  }
  {
    warranty-id: uint,
    customer: principal,
    purchase-date: uint,
    warranty-end-date: uint,
    device-type: (string-ascii 30),
    warranty-terms: (string-ascii 200),
    purchase-price: uint,
    status: (string-ascii 20)
  }
)

(define-map warranty-claims
  { claim-id: uint }
  {
    warranty-id: uint,
    customer: principal,
    dealer: principal,
    claim-date: uint,
    issue-description: (string-ascii 300),
    claim-status: (string-ascii 20),
    resolution: (string-ascii 200)
  }
)

(define-map return-requests
  {
    customer: principal,
    device-id: (string-ascii 50)
  }
  {
    request-id: uint,
    dealer: principal,
    request-date: uint,
    reason: (string-ascii 200),
    status: (string-ascii 20),
    refund-amount: uint
  }
)

(define-map warranty-counter
  { counter: (string-ascii 10) }
  { value: uint }
)

(define-map claim-counter
  { counter: (string-ascii 10) }
  { value: uint }
)

;; Initialize counters
(map-set warranty-counter { counter: "warranties" } { value: u0 })
(map-set claim-counter { counter: "claims" } { value: u0 })

;; Private Functions
(define-private (get-next-warranty-id)
  (let ((current-count (default-to u0 (get value (map-get? warranty-counter { counter: "warranties" })))))
    (let ((next-id (+ current-count u1)))
      (map-set warranty-counter { counter: "warranties" } { value: next-id })
      next-id
    )
  )
)

(define-private (get-next-claim-id)
  (let ((current-count (default-to u0 (get value (map-get? claim-counter { counter: "claims" })))))
    (let ((next-id (+ current-count u1)))
      (map-set claim-counter { counter: "claims" } { value: next-id })
      next-id
    )
  )
)

(define-private (is-warranty-valid (warranty-end-date uint))
  (> warranty-end-date block-height)
)

;; Public Functions
(define-public (create-warranty
  (customer principal)
  (device-id (string-ascii 50))
  (device-type (string-ascii 30))
  (warranty-days uint)
  (warranty-terms (string-ascii 200))
  (purchase-price uint)
)
  (let (
    (dealer tx-sender)
    (warranty-id (get-next-warranty-id))
    (current-time block-height)
    (warranty-end (+ current-time warranty-days))
  )
    (asserts! (>= warranty-days (var-get min-warranty-days)) ERR-INVALID-WARRANTY)
    (asserts! (> (len device-id) u0) ERR-INVALID-INPUT)
    (asserts! (> (len device-type) u0) ERR-INVALID-INPUT)
    (asserts! (> purchase-price u0) ERR-INVALID-INPUT)

    (map-set device-warranties
      { dealer: dealer, device-id: device-id }
      {
        warranty-id: warranty-id,
        customer: customer,
        purchase-date: current-time,
        warranty-end-date: warranty-end,
        device-type: device-type,
        warranty-terms: warranty-terms,
        purchase-price: purchase-price,
        status: "active"
      }
    )

    (ok warranty-id)
  )
)

(define-public (file-warranty-claim
  (dealer principal)
  (device-id (string-ascii 50))
  (issue-description (string-ascii 300))
)
  (let (
    (customer tx-sender)
    (claim-id (get-next-claim-id))
    (current-time block-height)
  )
    (match (map-get? device-warranties { dealer: dealer, device-id: device-id })
      warranty-data (begin
        (asserts! (is-eq (get customer warranty-data) customer) ERR-NOT-AUTHORIZED)
        (asserts! (is-warranty-valid (get warranty-end-date warranty-data)) ERR-WARRANTY-EXPIRED)
        (asserts! (> (len issue-description) u0) ERR-INVALID-INPUT)

        (map-set warranty-claims
          { claim-id: claim-id }
          {
            warranty-id: (get warranty-id warranty-data),
            customer: customer,
            dealer: dealer,
            claim-date: current-time,
            issue-description: issue-description,
            claim-status: "pending",
            resolution: ""
          }
        )

        (ok claim-id)
      )
      ERR-INVALID-WARRANTY
    )
  )
)

(define-public (process-warranty-claim
  (claim-id uint)
  (resolution (string-ascii 200))
  (approved bool)
)
  (let ((dealer tx-sender))
    (match (map-get? warranty-claims { claim-id: claim-id })
      claim-data (begin
        (asserts! (is-eq (get dealer claim-data) dealer) ERR-NOT-AUTHORIZED)
        (asserts! (is-eq (get claim-status claim-data) "pending") ERR-ALREADY-PROCESSED)

        (map-set warranty-claims
          { claim-id: claim-id }
          (merge claim-data {
            claim-status: (if approved "approved" "denied"),
            resolution: resolution
          })
        )

        (ok true)
      )
      ERR-CLAIM-NOT-FOUND
    )
  )
)

(define-public (request-return
  (dealer principal)
  (device-id (string-ascii 50))
  (reason (string-ascii 200))
)
  (let (
    (customer tx-sender)
    (current-time block-height)
  )
    (match (map-get? device-warranties { dealer: dealer, device-id: device-id })
      warranty-data (begin
        (asserts! (is-eq (get customer warranty-data) customer) ERR-NOT-AUTHORIZED)
        (asserts! (<= (- current-time (get purchase-date warranty-data)) (var-get max-return-days)) ERR-WARRANTY-EXPIRED)

        (map-set return-requests
          { customer: customer, device-id: device-id }
          {
            request-id: u1,
            dealer: dealer,
            request-date: current-time,
            reason: reason,
            status: "pending",
            refund-amount: (get purchase-price warranty-data)
          }
        )

        (ok true)
      )
      ERR-INVALID-WARRANTY
    )
  )
)

;; Read-only Functions
(define-read-only (get-warranty-info (dealer principal) (device-id (string-ascii 50)))
  (map-get? device-warranties { dealer: dealer, device-id: device-id })
)

(define-read-only (get-claim-info (claim-id uint))
  (map-get? warranty-claims { claim-id: claim-id })
)

(define-read-only (get-return-request (customer principal) (device-id (string-ascii 50)))
  (map-get? return-requests { customer: customer, device-id: device-id })
)

(define-read-only (get-min-warranty-days)
  (var-get min-warranty-days)
)

(define-read-only (get-max-return-days)
  (var-get max-return-days)
)
