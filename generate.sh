#!/bin/bash

# This file is part of Loqa (https://github.com/loqalabs/loqa).
# Copyright (C) 2025 Loqa Labs
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

set -e

echo "🔧 Generating protocol buffer bindings..."

# Clean and create output directories (preserve go.sum)
if [ -f go/go.sum ]; then
    cp go/go.sum /tmp/go.sum.backup
fi
rm -rf go/
mkdir -p go/audio go/whisper
if [ -f /tmp/go.sum.backup ]; then
    mv /tmp/go.sum.backup go/go.sum
fi

# Generate Go bindings
protoc --go_out=go/ --go-grpc_out=go/ \
    --go_opt=paths=source_relative \
    --go-grpc_opt=paths=source_relative \
    audio.proto whisper.proto

# Move generated files to correct subdirectories
mv go/audio*.pb.go go/audio/ 2>/dev/null || true
mv go/whisper*.pb.go go/whisper/ 2>/dev/null || true

# Create go.mod if it doesn't exist
if [ ! -f go/go.mod ]; then
    cat > go/go.mod << 'EOF'
module github.com/loqalabs/loqa-proto/go

go 1.24

require (
	google.golang.org/grpc v1.65.0
	google.golang.org/protobuf v1.34.2
)

require (
	golang.org/x/net v0.26.0 // indirect
	golang.org/x/sys v0.21.0 // indirect
	golang.org/x/text v0.16.0 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20240604185151-ef581f913117 // indirect
)
EOF
fi

echo "✅ Generated Go bindings in go/ directory"

# Future: Generate bindings for other languages
# protoc --python_out=python/ audio.proto
# protoc --js_out=javascript/ audio.proto

echo "🎯 Protocol buffer generation complete!"