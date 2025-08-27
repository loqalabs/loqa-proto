#!/bin/bash
set -e

echo "🔧 Generating protocol buffer bindings..."

# Create output directory if it doesn't exist
mkdir -p go

# Generate Go bindings
protoc --go_out=go/ --go-grpc_out=go/ \
    --go_opt=paths=source_relative \
    --go-grpc_opt=paths=source_relative \
    audio.proto

echo "✅ Generated Go bindings in go/ directory"

# Future: Generate bindings for other languages
# protoc --python_out=python/ audio.proto
# protoc --js_out=javascript/ audio.proto

echo "🎯 Protocol buffer generation complete!"