[![Sponsor](https://img.shields.io/badge/Sponsor-Loqa-ff69b4?logo=githubsponsors&style=for-the-badge)](https://github.com/sponsors/annabarnes1138)
[![Ko-fi](https://img.shields.io/badge/Buy%20me%20a%20coffee-Ko--fi-FF5E5B?logo=ko-fi&logoColor=white&style=for-the-badge)](https://ko-fi.com/annabarnes)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL--3.0-blue?style=for-the-badge)](LICENSE)
[![Made with ❤️ by LoqaLabs](https://img.shields.io/badge/Made%20with%20%E2%9D%A4%EF%B8%8F-by%20LoqaLabs-ffb6c1?style=for-the-badge)](https://loqalabs.com)

# 📡 Loqa Proto

[![CI/CD Pipeline](https://github.com/loqalabs/loqa-proto/actions/workflows/ci.yml/badge.svg)](https://github.com/loqalabs/loqa-proto/actions/workflows/ci.yml)

Shared gRPC protocol definitions and generated bindings for the Loqa platform.

## Overview

Loqa Proto contains:
- Protocol buffer definitions (.proto files)
- Generated client/server code for multiple languages
- Shared data structures and service interfaces
- Version-controlled API contracts

## Protocol Definitions

### Audio Service
- Audio streaming from pucks to hub
- Real-time audio data transmission
- Metadata and configuration

### Command Protocol
- Device command structures
- Intent parsing results
- Status and response messages

## Supported Languages

- Go (primary)
- Future: Python, JavaScript/TypeScript, C++ (for embedded)

## Features

- 🔌 **Multi-Language**: Generated bindings for multiple programming languages
- 📋 **Type Safety**: Strongly typed protocol definitions
- 🔄 **Versioning**: Backward-compatible API evolution
- 🚀 **Performance**: High-performance binary serialization
- 📖 **Documentation**: Auto-generated API documentation

## Usage

Include this repository as a dependency in Loqa services to access shared protocol definitions and generated client libraries.

### Go Consumers

For Go projects, use the `bindings/go` branch (which contains only the `artifact_bindings/` directory) to import the generated Go bindings. You can use a `replace` directive in your `go.mod` to point to the correct branch. For example:

```
replace github.com/loqalabs/loqa-proto => github.com/loqalabs/loqa-proto bindings/go
```

This ensures your project uses the latest generated Go code from the `artifact_bindings/` directory in the `bindings/go` branch.

## Code Generation

Protocol buffer compilation and code generation is handled automatically. Generated bindings for supported languages are produced by GitHub Actions workflows (CI/CD), so you do not need to run local build scripts unless developing or updating the protocol definitions.

## Getting Started

See the main [Loqa documentation](https://github.com/loqalabs/loqa) for setup and usage instructions.

## License

Licensed under the GNU Affero General Public License v3.0. See [LICENSE](LICENSE) for details.