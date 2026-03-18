# Agarvibe Backend - 众艺链海南 AI 沉香手串后端项目

## 📋 项目概述

众艺链 (Agarvibe) 是一款融合传统沉香文化、五行哲学、AI 智能体与区块链技术的创新产品。本项目为后端服务集群，采用 Go + Gin 微服务架构，AI 模块使用 Python/TypeScript 独立部署。

### 核心特性

- 🔐 **Web3 钱包集成** - 支持 MetaMask、WalletConnect 登录
- 📱 **NFC 设备绑定** - 近场通信验证手串真伪
- 🧠 **AI 记忆生成** - 基于 LLM 的五行文化智能对话
- 🎨 **NFT 数字藏品** - BSC 区块链 NFT 铸造与交易
- 💰 **双通道支付** - 法币 (Stripe/PayPal) + 加密货币 (BNB/BUSD)
- 👥 **社群互动** - 动态广场、点赞评论、活动管理

---

## 🏗️ 技术架构

### 主技术栈

| 组件 | 技术选型 |
|------|----------|
| **开发语言** | Go 1.22+ (主业务), Python 3.11+ (AI 服务) |
| **Web 框架** | Gin v1.9+, FastAPI 0.100+ |
| **数据库** | PostgreSQL 15 (关系型), MongoDB 7 (文档型) |
| **缓存** | Redis 7 (缓存/会话/队列) |
| **消息队列** | NATS 2.10+ (事件总线) |
| **区块链** | go-ethereum 1.13+ (BSC 交互) |
| **AI 框架** | LangChain + OpenAI/Claude API |
| **部署** | Kubernetes (EKS), Docker, ArgoCD |

### 微服务划分

```
agarvibe-backend/
├── services/
│   ├── auth-service/          # 认证授权服务
│   ├── user-service/          # 用户服务
│   ├── device-service/        # NFC 设备绑定服务
│   ├── memory-service/        # 记忆管理服务
│   ├── nft-service/           # 区块链 NFT 服务
│   ├── market-service/        # 交易市场服务
│   ├── payment-service/       # 支付服务
│   ├── community-service/     # 社群互动服务
│   └── ai-service/            # AI 微服务 (Python/TS)
├── docs/                      # 架构设计文档
├── configs/                   # 配置文件模板
└── scripts/                   # 运维脚本
```

---

## 📚 文档导航

### 核心文档

| 文档 | 说明 |
|------|------|
| [微服务划分设计](./docs/01-微服务划分设计.md) | 服务职责边界、通信机制、事件流 |
| [数据库 Schema 设计](./docs/02-数据库 Schema 设计.md) | PostgreSQL/MongoDB/Redis表结构 |
| [API 接口规范](./docs/03-API 接口规范文档.md) | RESTful API、gRPC、WebSocket 接口 |
| [架构设计总览](./docs/04-架构设计总览.md) | 系统拓扑、数据流、技术选型 |
| [部署架构](./docs/05-部署架构文档.md) | K8s 配置、CI/CD、监控告警 |
| [安全设计规范](./docs/06-安全设计规范文档.md) | 认证授权、加密、合规 |

### 快速开始

- [开发环境搭建指南](./docs/guides/dev-setup.md)
- [本地运行教程](./docs/guides/local-run.md)
- [部署到 Staging](./docs/guides/deploy-staging.md)

---

## 🚀 快速开始

### 前置要求

- Go 1.22+
- Python 3.11+ (AI 服务)
- Docker & Docker Compose
- PostgreSQL 15+
- Redis 7+
- NATS Server 2.10+

### 本地开发

```bash
# 1. 克隆项目
git clone https://github.com/agarvibe/agarvibe-backend.git
cd agarvibe-backend

# 2. 启动基础设施 (Docker Compose)
docker-compose up -d postgres redis nats

# 3. 运行数据库迁移
make migrate

# 4. 启动所有服务 (开发模式)
make dev

# 或单独启动某个服务
make run-auth-service
make run-memory-service
```

### 运行测试

```bash
# 单元测试
make test

# 集成测试
make test-integration

# 代码覆盖率
make coverage
```

---

## 🔑 核心功能

### 1. 认证授权 (Auth Service)

```go
// JWT + SIWE (Sign-In with Ethereum) 双模认证
POST /api/v1/auth/register      // 手机号/邮箱注册
POST /api/v1/auth/login         // 密码登录
POST /api/v1/auth/wallet/login  // 钱包签名登录
POST /api/v1/auth/token/refresh // 刷新 Token
```

### 2. NFC 设备绑定 (Device Service)

```go
POST /api/v1/devices/nfc/verify  // 验证 NFC 芯片
POST /api/v1/devices/bind        // 绑定手串
GET  /api/v1/devices             // 获取已绑定的手串列表
```

### 3. 记忆管理 (Memory Service)

```go
POST /api/v1/memories                 // 创建记忆 (文字/照片/语音)
GET  /api/v1/memories                 // 记忆时间轴
POST /api/v1/memories/:id/ai-generate // 触发 AI 生成摘要
```

### 4. NFT 区块链 (NFT Service)

```go
GET  /api/v1/nfts                     // 获取 NFT 列表
GET  /api/v1/nfts/:token_id/provenance // 溯源信息
POST /api/v1/nfts/:token_id/transfer  // 转移 NFT
```

### 5. AI 服务 (AI Service - Python)

```python
# 记忆摘要生成
POST /api/v1/ai/memory/summary

# 五行 AI 对话 (流式 SSE)
POST /api/v1/ai/chat

# 今日运势生成
POST /api/v1/ai/fortune/daily

# 与手串对话
POST /api/v1/ai/bracelet/talk
```

---

## 📊 监控与运维

### Prometheus 指标

```bash
# 访问 Dashboard
kubectl port-forward svc/grafana 3000:80
# http://localhost:3000
```

### 日志查询

```bash
# Kibana
kubectl port-forward svc/kibana 5601:80
# http://localhost:5601
```

### 链路追踪

```bash
# Jaeger
kubectl port-forward svc/jaeger-query 16686:80
# http://localhost:16686
```

---

## 🔒 安全合规

- ✅ GDPR/CCPA隐私合规
- ✅ PCI DSS 支付卡行业数据安全标准
- ✅ SOC 2 Type II 审计
- ✅ 智能合约第三方审计 (CertiK)

---

## 📦 版本发布

### 版本号规则

遵循语义化版本 (Semantic Versioning): `MAJOR.MINOR.PATCH`

- **MAJOR**: 不兼容的 API 变更
- **MINOR**: 向后兼容的功能新增
- **PATCH**: 向后兼容的问题修复

### 发布流程

```bash
# 1. 打 Tag
git tag v1.2.0
git push origin v1.2.0

# 2. GitHub Actions 自动构建并部署到 Staging
# 3. 测试通过后手动批准部署到 Production
```

---

## 🤝 贡献指南

### 开发流程

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交变更 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 提交 Pull Request

### 代码规范

- Go: 遵循 [Effective Go](https://golang.org/doc/effective_go.html)
- Python: 遵循 [PEP 8](https://pep8.org/)
- 提交信息遵循 [Conventional Commits](https://www.conventionalcommits.org/)

---

## 📄 许可证

Copyright © 2026 Agarvibe. All rights reserved.

---

## 📞 联系方式

- **技术支持**: tech@agarvibe.com
- **商务合作**: business@agarvibe.com
- **安全报告**: security@agarvibe.com

---

## 🙏 致谢

感谢以下开源项目:

- [Gin Web Framework](https://gin-gonic.com/)
- [GORM](https://gorm.io/)
- [go-ethereum](https://geth.ethereum.org/)
- [LangChain](https://langchain.com/)
- [FastAPI](https://fastapi.tiangolo.com/)
