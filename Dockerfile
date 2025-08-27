FROM golang:1.21-alpine AS builder

# Install protobuf compiler
RUN apk add --no-cache \
    protobuf \
    protobuf-dev \
    git

# Install Go protobuf plugins
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

WORKDIR /app
COPY . .

# Generate protobuf files
RUN protoc --go_out=go/ --go-grpc_out=go/ \
    --go_opt=paths=source_relative \
    --go-grpc_opt=paths=source_relative \
    audio.proto

FROM scratch
COPY --from=builder /app/go/ /proto/
COPY --from=builder /app/audio.proto /proto/