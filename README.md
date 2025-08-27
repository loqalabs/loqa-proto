# 📡 Loqa Proto

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

## Code Generation

Protocol buffer compilation and code generation is handled automatically via build scripts.

## Getting Started

See the main [Loqa documentation](https://github.com/loqalabs/loqa-docs) for setup and usage instructions.

## License

Licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.