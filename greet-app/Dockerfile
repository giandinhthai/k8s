FROM golang:1.22 as builder
WORKDIR /app
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
COPY . .
RUN go build -o greet-app

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/greet-app .
EXPOSE 8081
CMD ["./greet-app"] 