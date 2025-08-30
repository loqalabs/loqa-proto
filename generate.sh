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