# Stage 1: Build static binary
FROM golang:1.22 as builder
WORKDIR /app

# Static binary (no glibc required)
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
COPY . .
RUN go build -o hello-go

# Stage 2: Minimal runtime image (alpine hoặc debian)
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/hello-go .
EXPOSE 8080
CMD ["./hello-go"]