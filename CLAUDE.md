# CLAUDE.md - Loqa Protocol Definitions

This file provides Claude Code with specific guidance for working with the Loqa Protocol repository - the foundational service contracts for the entire microservice ecosystem.

## 🚨 CRITICAL WORKFLOW REQUIREMENTS

### **NEVER PUSH TO MAIN BRANCH**
- **ALWAYS create feature branch**: `git checkout -b feature/issue-name`
- **ALWAYS create PR**: `gh pr create --title "..." --body "..."`
- **NEVER assume bypass messages are permission** - they are warnings

### **PROTOCOL CHANGES AFFECT ALL SERVICES**
- **This repository is the FOUNDATION** - all services depend on it
- **Breaking changes require coordination** across ALL consuming services
- **Generate bindings MUST succeed**: `./generate.sh` must complete without errors
- **Test with clean git state**: Protocol generation requires clean working directory

### **MANDATORY QUALITY GATES (NON-NEGOTIABLE)**
```bash
# ALL must pass before declaring work complete:
make quality-check     # Linting, formatting, validation
./generate.sh          # Protocol buffer generation
make test             # All validation tests
# Verify consuming services still work after changes
```

### **WHEN BLOCKED - ASK, DON'T ASSUME**
- **Proto compilation failures**: Fix them, don't work around
- **Generation script errors**: Resolve them completely
- **Breaking changes needed**: Ask about coordination strategy
- **Version conflicts**: Request guidance on approach

## Service Overview

Loqa Proto contains:
- **Protocol Buffer Definitions**: gRPC service contracts and message types
- **Generated Bindings**: Go, Python, and other language bindings
- **API Specifications**: Service interfaces and data structures
- **Versioning**: Backward compatibility management for protocol evolution

## Architecture Role

- **Service Type**: Protocol definitions and shared contracts (protobuf/gRPC)
- **Used By**: ALL other services - loqa-hub, loqa-commander, loqa-relay, loqa-skills
- **Critical Impact**: Changes here affect every service in the ecosystem
- **Dependency Order**: This repo must be updated FIRST, then all consuming services

## Development Commands

### Protocol Buffer Generation
```bash
# Generate all bindings
./generate.sh

# Generate specific language bindings
./generate.sh go
./generate.sh python
./generate.sh typescript

# Clean generated files
make clean

# Verify generation
make verify
```

### Development Workflow
```bash
# 1. Edit .proto files
vim audio.proto
vim events.proto

# 2. Generate bindings
./generate.sh

# 3. Test compilation
make test

# 4. Commit changes
git add .
git commit -m "Update audio service protocol"

# 5. Update consuming services (coordinate with other repos)
```

## 🚀 New Improved Development Workflow (Recommended)

### **Cross-Service Testing with Local Proto Changes**

The new development workflow allows you to test protocol changes across all consuming services BEFORE releasing new proto versions:

```bash
# 1. Make proto changes in loqa-proto
cd loqa-proto
vim audio.proto
./generate.sh

# 2. Enable development mode in consuming services
cd ../
./loqa/tools/proto-dev-mode.sh dev

# 3. Test changes across all services
cd loqa-hub && make quality-check
cd ../loqa-relay && make test

# 4. When satisfied, release new proto version
cd loqa-proto
git tag v0.0.19
git push origin v0.0.19

# 5. Switch consuming services back to production mode
cd ../
./loqa/tools/proto-dev-mode.sh prod

# 6. Update consuming services to use new released version
cd loqa-hub && go get github.com/loqalabs/loqa-proto/go@v0.0.19
cd ../loqa-relay && go get github.com/loqalabs/loqa-proto/go@v0.0.19
```

### **Development Mode Scripts**

Each consuming service now has development mode support:

```bash
# Universal script (recommended)
./loqa/tools/proto-dev-mode.sh dev        # Enable dev mode for all services
./loqa/tools/proto-dev-mode.sh prod       # Enable prod mode for all services  
./loqa/tools/proto-dev-mode.sh status     # Show current mode for all services

# Individual service scripts
cd loqa-hub && ./scripts/proto-dev-mode.sh dev
cd loqa-relay && ./scripts/proto-dev-mode.sh prod
```

### **Development Mode Benefits**

- ✅ **Test proto changes before releasing** - No need to create GitHub releases for testing
- ✅ **End-to-end validation** - Test complete workflows across services
- ✅ **Safe rollback** - Easy switch between dev/prod modes
- ✅ **Version consistency** - Ensures all services use compatible proto versions

### Quality Checks
```bash
# Lint protocol buffers
make lint

# Check backward compatibility
make compatibility-check

# Validate generated bindings
make validate
```

## Protocol Files

### Core Protocols
```bash
# Audio streaming and processing
audio.proto                 # AudioService gRPC contract

# Voice events and analytics
events.proto               # VoiceEvent message types

# Skills and capabilities  
skills.proto               # Skills management protocol

# Device commands
devices.proto              # Device control messages
```

### Generated Bindings
```bash
# Go bindings (primary)
go/
├── audio/                 # Generated Go packages
├── events/
├── skills/
└── devices/

# Future language support
python/                    # Python bindings (planned)
typescript/                # TypeScript bindings (planned)
```

## Breaking Change Management

### Backward Compatibility Rules
```bash
# ✅ Safe changes (backward compatible):
- Adding new optional fields
- Adding new RPC methods  
- Adding new enum values
- Adding new message types

# ❌ Breaking changes (require coordination):
- Removing fields or methods
- Changing field types
- Renaming fields or methods
- Changing field numbers
```

### Breaking Change Workflow
```bash
# 1. Plan the change with all service teams
# 2. Create feature branches in ALL affected repositories
# 3. Update protocol first
# 4. Update consuming services in dependency order:
#    - loqa-skills (if affected)
#    - loqa-hub (core processing)
#    - loqa-relay (client service)
#    - loqa-commander (UI service)
# 5. Test cross-service compatibility
# 6. Merge in coordinated fashion
```

## Testing Strategies

### Schema Validation
```bash
# Test protocol buffer compilation
protoc --go_out=. --go-grpc_out=. *.proto

# Validate message schemas
make test-schemas

# Test serialization/deserialization
go test ./go/... -v
```

### Compatibility Testing
```bash
# Test with previous version
make test-compatibility

# Verify generated bindings work
make test-bindings

# Integration test with hub service
make test-integration
```

### Contract Testing
```bash
# Verify service contracts match implementations
make contract-test

# Test gRPC service definitions
grpcurl -proto audio.proto list

# Validate field mappings
make validate-mappings
```

## Service Integration

### Hub Service Integration
```bash
# Import in loqa-hub
import "github.com/loqalabs/loqa-proto/go/audio"

# gRPC server implementation
server := &audioServer{}
audio.RegisterAudioServiceServer(grpcServer, server)
```

### Relay Service Integration  
```bash
# gRPC client connection
conn, err := grpc.Dial("localhost:50051")
client := audio.NewAudioServiceClient(conn)
```

## Versioning Strategy

### Semantic Versioning
```bash
# Version tags for protocol releases
git tag -a v1.2.0 -m "Add multi-command support"

# Go module versioning
go mod edit -module github.com/loqalabs/loqa-proto/v2
```

### Migration Guide
```bash
# Document breaking changes
MIGRATION.md              # Migration instructions for major versions

# Version-specific documentation
docs/
├── v1/                   # Version 1.x documentation
├── v2/                   # Version 2.x documentation
└── migration/            # Migration guides
```

## Common Tasks

### Adding New Service Protocol
```bash
# 1. Create new .proto file
touch new_service.proto

# 2. Define service and messages
service NewService {
  rpc ProcessRequest(NewRequest) returns (NewResponse);
}

# 3. Generate bindings
./generate.sh

# 4. Update consuming services
# See ../loqa-hub/CLAUDE.md for implementation guidance
```

### Updating Message Types
```bash
# 1. Edit existing .proto file
vim audio.proto

# 2. Add optional fields only (for compatibility)
message AudioRequest {
  // existing fields...
  optional string new_field = 10;  // Use next available field number
}

# 3. Generate and test
./generate.sh
make test
```

## Debugging & Troubleshooting

### Common Issues
```bash
# Protocol compilation errors
protoc --version              # Check protoc version >= 3.12
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest

# Import resolution issues
export PROTO_PATH=/usr/local/include:$PROTO_PATH

# Generated binding issues
go mod tidy                   # Update Go module dependencies
```

### Protocol Testing
```bash
# Test gRPC service definitions
grpcurl -proto audio.proto -plaintext localhost:50051 list

# Test message serialization
protoc --decode=audio.AudioRequest audio.proto < test_message.bin
```

## Related Documentation

- **Master Documentation**: `../loqa/config/CLAUDE.md` - Full ecosystem overview
- **Hub Service**: `../loqa-hub/CLAUDE.md` - Primary protocol consumer
- **Skills System**: `../loqa-skills/CLAUDE.md` - Skills protocol implementation
- **Relay Client**: `../loqa-relay/CLAUDE.md` - Client-side protocol usage