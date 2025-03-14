# 第一阶段：构建阶段
FROM golang:alpine AS builder

# 设置工作目录
WORKDIR /app

# 安装必要的工具（如果需要 git 来拉取依赖）
RUN apk add --no-cache git

# 复制 go.mod 和 go.sum 文件（如果有）
COPY go.mod go.sum ./

# 下载依赖
RUN go mod download

# 复制项目源代码
COPY . .

# 编译 Go 程序
# -o 指定输出文件名，CGO_ENABLED=0 禁用 cgo 以生成静态二进制文件
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# 第二阶段：运行阶段
FROM alpine:latest

# 设置工作目录
WORKDIR /root/

# 从构建阶段复制编译好的二进制文件
COPY --from=builder /app/main .
COPY .env .

# 安装运行时可能需要的依赖（如果程序需要，例如证书）
RUN apk add --no-cache ca-certificates

# 暴露端口（如果你的 Go 项目是 HTTP 服务，根据需要修改）
EXPOSE 8080

# 运行程序
CMD ["./main"]