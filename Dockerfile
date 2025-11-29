FROM golang:1.23-alpine
RUN apk add --no-cache git
WORKDIR /app
RUN git clone https://github.com/erpc/erpc.git . && go build -o /app/erpc-bin ./cmd/erpc
COPY erpc.yaml /app/erpc.yaml
EXPOSE 4000 4001
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD wget --no-verbose --tries=1 --spider http://localhost:4001/health || exit 1
CMD ["./erpc-bin","-config","/app/erpc.yaml"]