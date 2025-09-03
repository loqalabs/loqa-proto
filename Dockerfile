FROM golang:1.24.0-alpine AS builder

# Install protobuf compiler
RUN apk add --no-cache \
    protobuf \
    git

# Install Go protobuf plugins
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.31.0
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.3.0

WORKDIR /app
COPY . .

# Generate protobuf files
RUN protoc --go_out=go/ --go-grpc_out=go/ \
    --go_opt=paths=source_relative \
    --go-grpc_opt=paths=source_relative \
    audio.proto

LABEL org.opencontainers.image.source="https://github.com/loqalabs/loqa-proto"
LABEL org.opencontainers.image.description="Builds and distributes protobuf definitions for Loqa"

FROM scratch
COPY --from=builder /app/go/ /proto/
COPY --from=builder /app/audio.proto /proto/