#!/bin/bash


set -e

COMMIT_CHANGES=false
for arg in "$@"; do
  if [[ "$arg" == "--commit" ]]; then
    COMMIT_CHANGES=true
  fi
done

# Check for uncommitted changes in go.mod or go.sum
if ! git diff --quiet go/go.mod go/go.sum; then
  echo "❌ Uncommitted changes in go.mod or go.sum. Please commit or stash before running."
  exit 1
fi

find go/ -type f ! -name 'go.mod' ! -name 'go.sum' -delete
find go/ -type d -empty -delete
mkdir -p go/audio go/whisper

protoc --go_out=go/ --go-grpc_out=go/ \
    --go_opt=paths=source_relative \
    --go-grpc_opt=paths=source_relative \
    audio.proto whisper.proto

mv go/audio*.pb.go go/audio/ 2>/dev/null || true
mv go/whisper*.pb.go go/whisper/ 2>/dev/null || true

echo "Generation complete."

if ! git diff --quiet go/; then
  if $COMMIT_CHANGES; then
    echo "✅ Committing updated Go bindings..."
    git add go/
    git commit -m 'Update generated protobuf bindings'
    echo "📤 Don't forget to push your changes:"
    echo "    git push"
  else
    echo "✅ Go bindings updated. Don't forget to commit the changes:"
    echo "    git add go/"
    echo "    git commit -m 'Update generated protobuf bindings'"
  fi
else
  echo "🟢 No changes to Go bindings"
fi