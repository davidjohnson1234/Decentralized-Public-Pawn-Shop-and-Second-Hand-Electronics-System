# Decentralized Public Pawn Shop and Second-Hand Electronics System

A comprehensive blockchain-based system for regulating and managing second-hand electronics transactions, ensuring consumer protection, preventing stolen goods trade, and maintaining transparency in the used electronics market.

## System Overview

This system consists of five interconnected smart contracts that work together to create a secure, transparent, and regulated environment for second-hand electronics trading:

### 1. Dealer Licensing Contract (`dealer-licensing.clar`)
- Issues and manages permits for businesses selling refurbished computers and phones
- Tracks licensing status, renewal dates, and compliance history
- Enables regulatory oversight of electronics dealers

### 2. Stolen Property Prevention Contract (`stolen-property-prevention.clar`)
- Maintains a database of stolen electronic device serial numbers
- Requires dealers to verify devices against the stolen property database
- Provides reporting mechanisms for stolen goods recovery

### 3. Consumer Protection Contract (`consumer-protection.clar`)
- Ensures used electronics come with appropriate warranties and return policies
- Manages warranty claims and dispute resolution
- Enforces minimum consumer protection standards

### 4. Data Wiping Verification Contract (`data-wiping-verification.clar`)
- Verifies that personal data has been properly removed from used devices
- Maintains certification records for data sanitization processes
- Ensures privacy protection for previous device owners

### 5. Price Transparency Contract (`price-transparency.clar`)
- Prevents deceptive pricing practices in second-hand electronics sales
- Maintains historical pricing data for market transparency
- Enables price comparison and fair market value determination

## Key Features

- **Regulatory Compliance**: Automated licensing and permit management
- **Fraud Prevention**: Serial number verification against stolen goods database
- **Consumer Protection**: Warranty management and dispute resolution
- **Privacy Protection**: Data wiping verification and certification
- **Market Transparency**: Fair pricing enforcement and historical data

## Contract Architecture

Each contract operates independently while maintaining data integrity across the system. The contracts use native Clarity data structures and functions without cross-contract dependencies.

## Getting Started

### Prerequisites
- Clarinet CLI
- Node.js and npm
- Vitest for testing

### Installation

1. Clone the repository
2. Install dependencies: \`npm install\`
3. Run tests: \`npm test\`
4. Deploy contracts: \`clarinet deploy\`

### Usage

Each contract provides specific functionality for different aspects of the second-hand electronics ecosystem. Refer to individual contract documentation for detailed usage instructions.

## Testing

The system includes comprehensive test suites using Vitest to ensure contract functionality and security. Tests cover:

- License issuance and management
- Stolen property verification
- Consumer protection enforcement
- Data wiping certification
- Price transparency validation

## Security Considerations

- All contracts implement proper access controls
- Input validation prevents malicious data entry
- Error handling ensures system stability
- Audit trails maintain transaction history

## Contributing

Please read the PR-DETAILS.md file for information about contributing to this project.

## License

This project is licensed under the MIT License.
