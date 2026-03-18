# Agarvibe Backend Services

众艺链海南 AI 沉香手串后端微服务项目

## 目录结构

```
services/
├── auth-service/          # 认证授权服务 (Go)
│   ├── cmd/
│   │   └── main.go
│   ├── internal/
│   │   ├── handler/
│   │   ├── service/
│   │   ├── repository/
│   │   └── middleware/
│   ├── pkg/
│   │   ├── jwt/
│   │   ├── siwe/
│   │   └── validator/
│   ├── config/
│   │   └── config.yaml
│   ├── Dockerfile
│   └── go.mod
│
├── user-service/          # 用户服务 (Go)
├── device-service/        # NFC 设备服务 (Go)
├── memory-service/        # 记忆管理服务 (Go)
├── nft-service/           # NFT 区块链服务 (Go)
├── market-service/        # 交易市场服务 (Go)
├── payment-service/       # 支付服务 (Go)
├── community-service/     # 社群互动服务 (Go)
│
└── ai-service/            # AI 微服务 (Python/FastAPI)
    ├── app/
    │   ├── main.py
    │   ├── api/
    │   │   └── v1/
    │   │       ├── memory.py
    │   │       ├── chat.py
    │   │       └── fortune.py
    │   ├── core/
    │   │   ├── llm.py
    │   │   ├── rag.py
    │   │   └── prompts.py
    │   ├── models/
    │   └── schemas/
    ├── requirements.txt
    └── Dockerfile
```

## 开发指南

### 1. 创建新服务

```bash
# 使用模板创建新服务
./scripts/create-service.sh my-new-service
```

### 2. 添加数据库迁移

```bash
# PostgreSQL 迁移
migrate create -ext sql -dir migrations/postgresql add_users_table

# MongoDB 迁移 (JavaScript)
node scripts/mongodb/create_indexes.js
```

### 3. 运行测试

```bash
# 单元测试
cd services/auth-service
go test -v ./...

# 集成测试 (需要 Docker)
make test-integration
```

## 环境变量

每个服务需要配置以下环境变量:

```bash
# 应用配置
APP_ENV=development
LOG_LEVEL=debug
APP_PORT=8080

# 数据库
DB_HOST=localhost
DB_PORT=5432
DB_NAME=agarvibe_dev
DB_USER=postgres
DB_PASSWORD=secret

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# NATS
NATS_URL=nats://localhost:4222

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRY=24h

# AWS (用于 S3/KMS)
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_S3_BUCKET=agarvibe-dev

# OpenAI (AI Service)
OPENAI_API_KEY=
```

## 常用命令

```bash
# 构建所有服务
make build

# 运行所有服务 (开发模式)
make dev

# 运行单个服务
make run-auth-service

# 代码格式化
make fmt

# 代码检查
make lint

# 生成 API 文档
make docs

# 清理构建产物
make clean
```

## 依赖管理

### Go 服务

```bash
# 更新依赖
go mod tidy

# 升级特定依赖
go get -u github.com/gin-gonic/gin

# 审查漏洞
govulncheck
```

### Python AI 服务

```bash
# 安装依赖
pip install -r requirements.txt

# 更新依赖
pipreqs . --force

# 安全扫描
safety check
```

## 监控指标

每个服务必须暴露 `/metrics` 端点供 Prometheus 抓取:

```go
// Go 服务 (使用 promhttp)
import "github.com/prometheus/client_golang/prometheus/promhttp"

router.GET("/metrics", gin.WrapH(promhttp.Handler()))
```

```python
# Python 服务 (使用 prometheus_fastapi_instrumentator)
from prometheus_fastapi_instrumentator import Instrumentator

instrumentator.instrument(app).expose(app)
```

## 日志规范

采用结构化日志 (JSON 格式):

```json
{
  "timestamp": "2026-03-18T10:30:00Z",
  "level": "info",
  "service": "auth-service",
  "trace_id": "abc-123-xyz",
  "span_id": "001",
  "message": "User login successful",
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "ip": "192.168.1.100"
}
```

## 健康检查

每个服务必须实现健康检查端点:

```go
// GET /health/live  - 存活探针 (进程是否活着)
// GET /health/ready - 就绪探针 (是否可以接收流量)

router.GET("/health/live", func(c *gin.Context) {
    c.JSON(200, gin.H{"status": "ok"})
})

router.GET("/health/ready", func(c *gin.Context) {
    // 检查数据库连接、Redis 连接等
    if err := checkDependencies(); err != nil {
        c.JSON(503, gin.H{"status": "unavailable"})
        return
    }
    c.JSON(200, gin.H{"status": "ok"})
})
```
