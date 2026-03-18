# 众艺链海南 AI 沉香手串 - 后端架构设计文档汇总

**项目**: Agarvibe Backend  
**版本**: 1.0  
**创建日期**: 2026 年 3 月 18 日  
**技术负责人**: [待填写]

---

## 📋 文档清单

本文档集为"众艺链海南 AI 沉香手串"项目提供完整的后端架构设计和开发规范。所有文档均位于 `agarvibe-backend/docs/` 目录下。

### 核心设计文档 (6 份)

| 编号 | 文档名称 | 文件路径 | 主要内容 | 目标读者 |
|------|----------|----------|----------|----------|
| **01** | [微服务划分设计](./01-微服务划分设计.md) | `docs/01-微服务划分设计.md` | • 9 大微服务职责边界<br>• 服务间通信机制 (REST/gRPC/NATS)<br>• AI 微服务独立部署方案<br>• 事件驱动架构设计 | 架构师<br>后端开发 |
| **02** | [数据库 Schema 设计](./02-数据库 Schema 设计.md) | `docs/02-数据库 Schema 设计.md` | • PostgreSQL 完整表结构 (20+ 表)<br>• MongoDB 文档模型设计<br>• Redis 数据结构与缓存策略<br>• Elasticsearch 搜索索引 | 后端开发<br>DBA |
| **03** | [API 接口规范](./03-API 接口规范文档.md) | `docs/03-API 接口规范文档.md` | • RESTful API 设计原则<br>• 完整 API 端点定义 (100+)<br>• 错误码规范<br>• WebSocket/gRPC 接口 | 前后端开发<br>测试工程师 |
| **04** | [架构设计总览](./04-架构设计总览.md) | `docs/04-架构设计总览.md` | • 系统全景架构图<br>• 技术栈选型说明<br>• 核心业务流程图<br>• 数据分布与同步策略 | 架构师<br>技术负责人 |
| **05** | [部署架构文档](./05-部署架构文档.md) | `docs/05-部署架构文档.md` | • Kubernetes 集群配置<br>• CI/CD流水线 (GitHub Actions+ArgoCD)<br>• 监控告警配置<br>• 备份恢复策略 | DevOps<br>SRE |
| **06** | [安全设计规范](./06-安全设计规范文档.md) | `docs/06-安全设计规范文档.md` | • JWT/SIWE 认证实现<br>• 数据加密策略<br>• OWASP Top 10 防护<br>• GDPR 合规方案 | 安全工程师<br>后端开发 |

### 配套文档

| 文档 | 文件路径 | 用途 |
|------|----------|------|
| README | `README.md` | 项目概述、快速开始、文档导航 |
| 服务指南 | `services/README.md` | 微服务开发指南、环境变量、常用命令 |
| 配置模板 | `configs/config.example.yaml` | 生产环境配置参考 |

---

## 🎯 使用指南

### 按角色推荐阅读顺序

#### 架构师 / 技术负责人
```
04-架构设计总览 → 01-微服务划分设计 → 05-部署架构 → 06-安全设计规范
```

#### 后端开发工程师
```
03-API 接口规范 → 02-数据库 Schema 设计 → 01-微服务划分设计 → services/README.md
```

#### DevOps 工程师
```
05-部署架构 → 04-架构设计总览 (第 7-10 章) → configs/config.example.yaml
```

#### 测试工程师
```
03-API 接口规范 → 06-安全设计规范 (第 9 章 安全测试) → 01-微服务划分设计 (第 6 章 监控)
```

#### 安全工程师
```
06-安全设计规范 → 04-架构设计总览 (第 6 章 安全架构) → 02-数据库 Schema 设计 (第 4 章 数据安全)
```

---

## 📊 核心架构决策摘要

### 技术选型

| 决策点 | 选择 | 理由 |
|--------|------|------|
| **主语言** | Go 1.22+ | 高性能、并发友好、部署简单 |
| **AI 服务** | Python + FastAPI | LangChain 生态成熟、Prompt 工程工具链完善 |
| **Web 框架** | Gin | 轻量级、性能优异、中间件丰富 |
| **数据库** | PostgreSQL + MongoDB | 关系型 (事务) + 文档型 (灵活扩展) |
| **消息队列** | NATS | 云原生、性能卓越、支持事件流 |
| **区块链** | go-ethereum | BSC 官方 Go 实现、底层兼容性好 |
| **容器编排** | Kubernetes (EKS) | 行业标准、自动扩缩容、高可用 |

### 微服务划分 (9 个服务)

```
1. Auth Service      - 认证授权 (JWT + SIWE)
2. User Service      - 用户资料管理
3. Device Service    - NFC 设备绑定
4. Memory Service    - 记忆管理 (MongoDB)
5. NFT Service       - 区块链 NFT 交互
6. Market Service    - 交易市场
7. Payment Service   - 双通道支付
8. Community Service - 社群互动
9. AI Service        - AI 对话/摘要生成 (Python)
```

### 关键设计模式

- **事件驱动架构**: NATS 事件总线解耦服务间依赖
- **CQRS 模式**: 读写分离 (PostgreSQL 主库写，只读副本读)
- **Saga 模式**: 分布式事务最终一致性 (购买流程)
- **多租户设计**: 基于用户 ID 的数据隔离
- **缓存策略**: 三级缓存 (本地→Redis→数据库)

---

## 🔑 核心技术指标

### 性能要求 (来自 PRD)

| 指标 | 目标值 | 保障措施 |
|------|--------|----------|
| NFC 响应时间 | ≤2 秒 | 边缘计算 + Redis 缓存 |
| 页面加载 | ≤2 秒 | CDN + 多级缓存 |
| 并发支持 | ≥1000 QPS | 水平扩展 + 负载均衡 |
| 区块链同步延迟 | ≤30 秒 | WebSocket 监听 + 事件驱动 |

### 可用性目标

| 等级 | 目标 | 实现方案 |
|------|------|----------|
| **服务可用性** | 99.9% | 多可用区部署 + 自动故障转移 |
| **数据持久性** | 99.999% | RDS Multi-AZ + 每日备份 |
| **灾备 RTO** | < 4 小时 | 跨区域 DR 环境 + Velero 备份 |
| **灾备 RPO** | < 1 小时 | WAL 归档 + 增量备份 |

---

## 🚀 开发路线图

### Phase 1: MVP (6-8 周)

**优先级 P0** - 必须实现
- [ ] Auth Service (基础认证)
- [ ] User Service (用户资料)
- [ ] Device Service (NFC 绑定)
- [ ] NFT Service (铸造 + 查询)
- [ ] Memory Service (基础 CRUD)
- [ ] AI Service (记忆摘要生成)

**基础设施**
- [ ] Kubernetes 集群搭建
- [ ] CI/CD流水线
- [ ] 基础监控 (Prometheus+Grafana)
- [ ] 日志聚合 (ELK)

### Phase 2: 交易市场 (4-6 周)

**优先级 P1** - 重要功能
- [ ] Market Service (商品/订单)
- [ ] Payment Service (Stripe/PayPal)
- [ ] NFT Service (转移 + 分红)
- [ ] 二级市场功能

### Phase 3: 社群与 AI 增强 (4 周)

**优先级 P1** - 增强体验
- [ ] Community Service (动态/评论)
- [ ] AI Service (五行对话 + 运势)
- [ ] WebSocket 实时推送
- [ ] 智能场景感知推荐

### Phase 4: 优化与扩展 (持续)

**优先级 P2** - 锦上添花
- [ ] 性能优化 (数据库调优 + 缓存策略)
- [ ] 多链支持 (Polygon/L2)
- [ ] AR 试戴功能预研
- [ ] 开放平台 API

---

## 📈 成功标准

### 技术指标

- [ ] 所有核心 API P95 延迟 < 500ms
- [ ] 系统可用性 > 99.9%
- [ ] 零 P0/P1 级别安全漏洞
- [ ] 单元测试覆盖率 > 80%
- [ ] 自动化部署成功率 > 99%

### 业务指标

- [ ] 支持 10,000+ DAU
- [ ] NFC 绑定成功率 > 99%
- [ ] AI 对话响应时间 < 3 秒
- [ ] 支付成功率 > 95%
- [ ] NFT 铸造上链成功率 > 98%

---

## 🔗 相关资源

### 外部依赖

- **BSC 节点**: https://bsc-dataseed.binance.org
- **OpenAI API**: https://api.openai.com
- **Stripe 支付**: https://api.stripe.com
- **IPFS 网关**: https://ipfs.io

### 内部资源

- **Figma 设计稿**: https://www.figma.com/design/PCBzOhgf2chqTuHDArYcLQ/agarwood
- **需求文档**: `../需求.md`
- **Flutter 前端**: `../agarwood_app/`

### 学习资源

- [Go 官方文档](https://golang.org/doc/)
- [Gin 框架文档](https://gin-gonic.com/docs/)
- [Kubernetes 权威指南](https://kubernetes.io/docs/home/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

---

## 📞 支持与反馈

如有任何疑问或建议，请联系:

- **技术讨论**: tech@agarvibe.com
- **文档改进**: docs@agarvibe.com
- **Bug 报告**: bugs@agarvibe.com

---

## 📝 修订历史

| 版本 | 日期 | 修订人 | 变更内容 |
|------|------|--------|----------|
| 1.0 | 2026-03-18 | 架构团队 | 初始版本发布 |
| | | | |

---

**最后更新**: 2026 年 3 月 18 日  
**下次评审**: 2026 年 6 月 18 日 (季度评审)
