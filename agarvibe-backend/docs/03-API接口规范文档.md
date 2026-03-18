# 众艺链海南 AI 沉香手串 - API 接口规范文档

**版本**: 1.0  
**日期**: 2026 年 3 月  
**API 风格**: RESTful + gRPC (内部) + WebSocket (实时)

---

## 1. API 设计原则

### 1.1 RESTful 规范

**URL 命名**:
- 使用小写字母，单词间用下划线分隔：`/api/v1/users/profile`
- 资源名使用复数：`/api/v1/memories`, `/api/v1/bracelets`
- 嵌套资源不超过两级：`/api/v1/users/:id/orders` ✅, `/api/v1/users/:id/orders/:oid/items` ❌

**HTTP 方法**:
```
GET     /api/v1/resource          # 获取资源列表
GET     /api/v1/resource/:id      # 获取单个资源
POST    /api/v1/resource          # 创建资源
PUT     /api/v1/resource/:id      # 全量更新资源
PATCH   /api/v1/resource/:id      # 部分更新资源
DELETE  /api/v1/resource/:id      # 删除资源
```

**请求/响应格式**:
```json
// 请求头
Content-Type: application/json
Authorization: Bearer {jwt_token}
X-Request-ID: {uuid}              // 用于链路追踪
X-Client-Version: 1.0.0           // App 版本
X-Device-Model: iPhone 15 Pro     // 设备型号

// 成功响应 (200 OK)
{
  "code": 0,
  "message": "success",
  "data": { ... },
  "meta": {
    "request_id": "abc-123-xyz",
    "timestamp": "2026-03-18T10:30:00Z"
  }
}

// 分页响应
{
  "code": 0,
  "message": "success",
  "data": [...],
  "meta": {
    "pagination": {
      "page": 1,
      "per_page": 20,
      "total": 150,
      "total_pages": 8
    }
  }
}

// 错误响应
{
  "code": 1001,
  "message": "用户未登录",
  "errors": {
    "field": "authorization",
    "detail": "Token 已过期"
  },
  "meta": {
    "request_id": "abc-123-xyz",
    "timestamp": "2026-03-18T10:30:00Z"
  }
}
```

### 1.2 状态码定义

**HTTP 状态码**:
```
200 OK          # 成功
201 Created     # 创建成功
204 No Content  # 删除成功 (无返回体)

400 Bad Request       # 请求参数错误
401 Unauthorized      # 未认证
403 Forbidden         # 无权限
404 Not Found         # 资源不存在
409 Conflict          # 资源冲突 (如重复绑定)
422 Unprocessable Entity  # 参数验证失败
429 Too Many Requests     # 请求频率超限

500 Internal Server Error # 服务器内部错误
502 Bad Gateway           # 上游服务错误
503 Service Unavailable   # 服务不可用
```

**业务错误码** (code 字段):
```
0      - 成功

1xxx   - 通用错误
1001   - 用户未登录
1002   - Token 无效
1003   - Token 已过期
1004   - 权限不足
1005   - 请求频率超限
1006   - 幂等性冲突

2xxx   - 用户域错误
2001   - 手机号已注册
2002   - 邮箱已注册
2003   - 密码错误
2004   - 用户不存在
2005   - 钱包地址格式错误
2006   - 钱包已绑定
2007   - KYC 审核中
2008   - KYC 未通过

3xxx   - 设备域错误
3001   - NFC 芯片不存在
3002   - 芯片已被绑定
3003   - 绑定关系不存在
3004   - NFC 验证超时
3005   - 手串不可用

4xxx   - 记忆域错误
4001   - 记忆不存在
4002   - 无权限访问该记忆
4003   - 媒体文件上传失败
4004   - AI 生成失败

5xxx   - NFT 域错误
5001   - NFT 铸造失败
5002   - NFT 不存在
5003   - 非 NFT 持有者
5004   - 转移失败
5005   - 区块链网络异常
5006   - Gas 费不足

6xxx   - 市场域错误
6001   - 商品不存在
6002   - 库存不足
6003   - 订单不存在
6004   - 订单状态不允许该操作
6005   - 上架不存在
6006   - 价格不合法

7xxx   - 支付域错误
7001   - 支付方式不支持
7002   - 支付失败
7003   - 汇率获取失败
7004   - 支付金额不匹配
7005   - 重复支付

8xxx   - AI 服务错误
8001   - AI 服务不可用
8002   - Prompt 过长
8003   - 内容违规
8004   - 生成超时
```

---

## 2. 认证授权 API

### 2.1 用户注册

```http
POST /api/v1/auth/register
Content-Type: application/json

// Request
{
  "phone": "+8613800138000",      // 或 email
  "email": "user@example.com",    // phone/email 二选一
  "password": "SecurePass123!",
  "nickname": "缘主",
  "invitation_code": "ABC123"     // 可选
}

// Response (201 Created)
{
  "code": 0,
  "message": "success",
  "data": {
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "nickname": "缘主",
    "avatar_url": null,
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
    "expires_in": 86400,
    "token_type": "Bearer"
  }
}
```

### 2.2 账号密码登录

```http
POST /api/v1/auth/login
Content-Type: application/json

// Request
{
  "phone": "+8613800138000",      // 或 email
  "password": "SecurePass123!"
}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": {
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "nickname": "缘主",
    "avatar_url": "https://storage.agarvibe.com/avatars/user_001.jpg",
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
    "expires_in": 86400,
    "token_type": "Bearer",
    "premium_level": "free"
  }
}
```

### 2.3 钱包签名登录 (SIWE)

```http
POST /api/v1/auth/wallet/challenge
Content-Type: application/json

// Request (获取签名挑战)
{
  "wallet_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": {
    "nonce": "abc123xyz",
    "message": "Welcome to Agarverse!\n\nSign this message to prove you own this wallet.\n\nNonce: abc123xyz\nIssued At: 2026-03-18T10:30:00Z",
    "expires_at": "2026-03-18T10:35:00Z"
  }
}

---

POST /api/v1/auth/wallet/login
Content-Type: application/json

// Request (提交签名)
{
  "wallet_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
  "signature": "0x1234567890abcdef...",
  "message": "Welcome to Agarverse!..."
}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": {
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "nickname": "缘主",
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
    "expires_in": 86400,
    "token_type": "Bearer"
  }
}
```

### 2.4 刷新 Token

```http
POST /api/v1/auth/token/refresh
Content-Type: application/json

// Request
{
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4..."
}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "bmV3IHJlZnJlc2ggdG9rZW4...",
    "expires_in": 86400,
    "token_type": "Bearer"
  }
}
```

### 2.5 登出

```http
POST /api/v1/auth/logout
Authorization: Bearer {jwt_token}

// Response (200 OK)
{
  "code": 0,
  "message": "success"
}
```

---

## 3. 用户服务 API

### 3.1 获取用户资料

```http
GET /api/v1/users/profile
Authorization: Bearer {jwt_token}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": {
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "nickname": "缘主",
    "avatar_url": "https://storage.agarvibe.com/avatars/user_001.jpg",
    "phone": "+86138****8000",
    "email": "use***@example.com",
    "premium_level": "free",
    "language": "zh-TW",
    "timezone": "Asia/Shanghai",
    "kyc_status": "pending",
    "wallet_bound": true,
    "wallet_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    "created_at": "2026-01-15T08:00:00Z",
    "preferences": {
      "theme_style": "oriental_minimal",
      "notifications": {
        "push_enabled": true,
        "email_enabled": false,
        "fortune_daily": true,
        "memory_reminder": true
      },
      "privacy": {
        "show_profile": true,
        "show_memories": false
      }
    }
  }
}
```

### 3.2 更新用户资料

```http
PUT /api/v1/users/profile
Authorization: Bearer {jwt_token}
Content-Type: application/json

// Request
{
  "nickname": "新昵称",
  "avatar_url": "https://storage.agarvibe.com/avatars/new_avatar.jpg"
}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": {
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "nickname": "新昵称",
    "avatar_url": "https://storage.agarvibe.com/avatars/new_avatar.jpg"
  }
}
```

### 3.3 更新偏好设置

```http
PUT /api/v1/users/preferences
Authorization: Bearer {jwt_token}
Content-Type: application/json

// Request
{
  "theme_style": "oriental_minimal",
  "language": "en-US",
  "notifications": {
    "push_enabled": true,
    "fortune_daily": false
  }
}

// Response (200 OK)
{
  "code": 0,
  "message": "success"
}
```

### 3.4 获取用户资产汇总

```http
GET /api/v1/users/assets/summary
Authorization: Bearer {jwt_token}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": {
    "nft_count": 3,
    "bracelet_count": 2,
    "memory_count": 15,
    "points_balance": 500,
    "total_spent_cents": 199000,
    "dividend_earned_cents": 5970
  }
}
```

---

## 4. 设备服务 API

### 4.1 验证 NFC 芯片

```http
POST /api/v1/devices/nfc/verify
Authorization: Bearer {jwt_token}
Content-Type: application/json

// Request
{
  "chip_id": "NFC001ABC123",
  "device_model": "iPhone 15 Pro",
  "os_version": "iOS 17.3"
}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": {
    "verified": true,
    "chip_status": "bound",
    "bracelet_id": "660e8400-e29b-41d4-a716-446655440001",
    "bracelet_name": "海南沉香·木韵",
    "is_owner": true,
    "binding_id": "770e8400-e29b-41d4-a716-446655440002"
  }
}
```

### 4.2 绑定手串

```http
POST /api/v1/devices/bind
Authorization: Bearer {jwt_token}
Content-Type: application/json

// Request
{
  "chip_id": "NFC001ABC123",
  "bracelet_nickname": "我的幸运手串",
  "confirm_info": {
    "category": "collector",
    "five_element": "木",
    "image_url": "https://storage.agarvibe.com/bracelets/img_001.jpg"
  }
}

// Response (201 Created)
{
  "code": 0,
  "message": "success",
  "data": {
    "binding_id": "770e8400-e29b-41d4-a716-446655440002",
    "bracelet_id": "660e8400-e29b-41d4-a716-446655440001",
    "bracelet_name": "海南沉香·木韵",
    "nft_minting": true,
    "nft_token_id": null
  }
}
```

### 4.3 获取已绑定的手串列表

```http
GET /api/v1/devices?page=1&per_page=10
Authorization: Bearer {jwt_token}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": [
    {
      "binding_id": "770e8400-e29b-41d4-a716-446655440002",
      "bracelet_id": "660e8400-e29b-41d4-a716-446655440001",
      "name": "海南沉香·木韵",
      "nickname": "我的幸运手串",
      "five_element": "木",
      "category": "collector",
      "image_url": "https://storage.agarvibe.com/bracelets/img_001.jpg",
      "bound_at": "2026-03-15T10:00:00Z",
      "last_interaction_at": "2026-03-18T09:30:00Z"
    }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "per_page": 10,
      "total": 1,
      "total_pages": 1
    }
  }
}
```

### 4.4 解绑手串

```http
DELETE /api/v1/devices/:binding_id/unbind
Authorization: Bearer {jwt_token}

// Response (200 OK)
{
  "code": 0,
  "message": "success"
}
```

### 4.5 修改手串昵称

```http
PUT /api/v1/devices/:bracelet_id/nickname
Authorization: Bearer {jwt_token}
Content-Type: application/json

// Request
{
  "nickname": "新的昵称"
}

// Response (200 OK)
{
  "code": 0,
  "message": "success"
}
```

---

## 5. 记忆服务 API

### 5.1 创建记忆

```http
POST /api/v1/memories
Authorization: Bearer {jwt_token}
Content-Type: multipart/form-data

// Request (FormData)
{
  "bracelet_id": "660e8400-e29b-41d4-a716-446655440001",
  "content": "今天在巴黎塞纳河畔冥想，感受着秋日的微风...",
  "media_type": "photo",
  "photos": [file1, file2],        // 图片文件
  "audio": file3,                   // 语音文件 (可选，≤10 秒)
  "location_name": "巴黎塞纳河畔",
  "location_lat": 48.8566,
  "location_lng": 2.3522,
  "tags": ["冥想", "旅行", "秋天"],
  "privacy": "private",
  "memory_date": "2026-03-18T10:00:00Z",
  "ai_generate_summary": true       // 是否触发 AI 生成摘要
}

// Response (201 Created)
{
  "code": 0,
  "message": "success",
  "data": {
    "memory_id": "64f5a1b2c3d4e5f6a7b8c9d0",
    "content_preview": "今天在巴黎塞纳河畔冥想...",
    "media_urls": [
      "https://storage.agarvibe.com/memories/user_001/20260318_001.jpg",
      "https://storage.agarvibe.com/memories/user_001/20260318_002.jpg"
    ],
    "ai_summary_generating": true,
    "created_at": "2026-03-18T10:30:00Z"
  }
}
```

### 5.2 获取记忆列表 (时间轴)

```http
GET /api/v1/memories?page=1&per_page=20&bracelet_id=xxx&tag=冥想
Authorization: Bearer {jwt_token}

// Query Parameters
// - page: 页码
// - per_page: 每页数量 (max 50)
// - bracelet_id: 筛选特定手串 (可选)
// - tag: 标签筛选 (可选)
// - start_date: 开始日期 (可选)
// - end_date: 结束日期 (可选)

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": [
    {
      "memory_id": "64f5a1b2c3d4e5f6a7b8c9d0",
      "bracelet_id": "660e8400-e29b-41d4-a716-446655440001",
      "bracelet_name": "海南沉香·木韵",
      "content_preview": "今天在巴黎塞纳河畔冥想...",
      "media_type": "photo",
      "media_cover_url": "https://storage.agarvibe.com/memories/user_001/20260318_001.jpg",
      "location_name": "巴黎塞纳河畔",
      "tags": ["冥想", "旅行"],
      "ai_summary": "秋天的第一次冥想，木火相生，能量满满",
      "privacy": "private",
      "is_favorite": false,
      "memory_date": "2026-03-18T10:00:00Z",
      "created_at": "2026-03-18T10:30:00Z"
    }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "per_page": 20,
      "total": 15,
      "total_pages": 1
    }
  }
}
```

### 5.3 获取记忆详情

```http
GET /api/v1/memories/:memory_id
Authorization: Bearer {jwt_token}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": {
    "memory_id": "64f5a1b2c3d4e5f6a7b8c9d0",
    "bracelet_id": "660e8400-e29b-41d4-a716-446655440001",
    "content": "今天在巴黎塞纳河畔冥想，感受着秋日的微风...",
    "media_type": "photo",
    "media_urls": [
      "https://storage.agarvibe.com/memories/user_001/20260318_001.jpg",
      "https://storage.agarvibe.com/memories/user_001/20260318_002.jpg"
    ],
    "audio_url": null,
    "location": {
      "name": "巴黎塞纳河畔",
      "lat": 48.8566,
      "lng": 2.3522,
      "address": "Paris, France"
    },
    "tags": ["冥想", "旅行", "秋天"],
    "privacy": "private",
    "ai_summary": "秋天的第一次冥想，木火相生，能量满满",
    "five_element_context": {
      "day_element": "木",
      "hour_element": "火",
      "weather": "晴朗"
    },
    "is_favorite": true,
    "memory_date": "2026-03-18T10:00:00Z",
    "created_at": "2026-03-18T10:30:00Z",
    "updated_at": "2026-03-18T11:00:00Z"
  }
}
```

### 5.4 更新记忆

```http
PUT /api/v1/memories/:memory_id
Authorization: Bearer {jwt_token}
Content-Type: application/json

// Request
{
  "content": "更新后的内容...",
  "tags": ["冥想", "巴黎", "新标签"],
  "privacy": "friends"
}

// Response (200 OK)
{
  "code": 0,
  "message": "success"
}
```

### 5.5 删除记忆

```http
DELETE /api/v1/memories/:memory_id
Authorization: Bearer {jwt_token}

// Response (200 OK)
{
  "code": 0,
  "message": "success"
}
```

### 5.6 触发 AI 生成摘要

```http
POST /api/v1/memories/:memory_id/ai-generate
Authorization: Bearer {jwt_token}

// Response (202 Accepted)
{
  "code": 0,
  "message": "AI 生成任务已提交",
  "data": {
    "task_id": "task_abc123",
    "estimated_seconds": 5
  }
}
```

### 5.7 获取记忆标签列表

```http
GET /api/v1/memories/tags
Authorization: Bearer {jwt_token}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": [
    {"tag": "冥想", "count": 10},
    {"tag": "旅行", "count": 5},
    {"tag": "秋天", "count": 3}
  ]
}
```

---

## 6. NFT 服务 API

### 6.1 获取 NFT 列表

```http
GET /api/v1/nfts?page=1&per_page=20
Authorization: Bearer {jwt_token}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": [
    {
      "nft_id": "uuid-001",
      "token_id": 2026031500001,
      "contract_address": "0x3B7E...9D1F",
      "chain_id": 56,
      "bracelet_id": "660e8400-e29b-41d4-a716-446655440001",
      "name": "海南沉香·木韵",
      "description": "源自海南岛的千年沉香手串...",
      "image_url": "https://storage.agarvibe.com/nfts/img_001.jpg",
      "attributes": {
        "element": "木",
        "age": 15,
        "origin": "海南",
        "weight": "25.6g"
      },
      "owner_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
      "minted_at": "2026-03-15T10:00:00Z"
    }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "per_page": 20,
      "total": 3,
      "total_pages": 1
    }
  }
}
```

### 6.2 获取 NFT 详情

```http
GET /api/v1/nfts/:token_id
Authorization: Bearer {jwt_token}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": {
    "nft_id": "uuid-001",
    "token_id": 2026031500001,
    "contract_address": "0x3B7E...9D1F",
    "chain_id": 56,
    "bracelet_id": "660e8400-e29b-41d4-a716-446655440001",
    "name": "海南沉香·木韵",
    "description": "源自海南岛的千年沉香手串，融合东方五行哲学...",
    "image_url": "https://storage.agarvibe.com/nfts/img_001.jpg",
    "animation_url": null,
    "external_url": "https://agarvibe.com/nft/2026031500001",
    "attributes": {
      "element": "木",
      "age": 15,
      "origin": "海南",
      "weight": "25.6g",
      "bead_count": 16
    },
    "metadata_uri": "ipfs://QmXxx...",
    "metadata_hash": "0xabc123...",
    "owner_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    "original_owner": "0xOriginalOwnerAddress...",
    "mint_tx_hash": "0xMintTxHash...",
    "status": "active"
  }
}
```

### 6.3 获取 NFT 流转历史

```http
GET /api/v1/nfts/:token_id/history
Authorization: Bearer {jwt_token}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": [
    {
      "tx_hash": "0xTransferTxHash...",
      "block_number": 35000000,
      "from_address": "0xPreviousOwner...",
      "to_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
      "transfer_type": "transfer",
      "price_cents": 50000,
      "timestamp": "2026-03-17T14:00:00Z"
    },
    {
      "tx_hash": "0xMintTxHash...",
      "block_number": 34000000,
      "from_address": "0x0000000000000000000000000000000000000000",
      "to_address": "0xOriginalOwner...",
      "transfer_type": "mint",
      "price_cents": null,
      "timestamp": "2026-03-15T10:00:00Z"
    }
  ]
}
```

### 6.4 获取溯源信息

```http
GET /api/v1/nfts/:token_id/provenance
Authorization: Bearer {jwt_token}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": {
    "origin": {
      "country": "中国",
      "province": "海南省",
      "city": "三亚市",
      "lat": 18.2528,
      "lng": 109.5117,
      "address": "海南省三亚市某某沉香基地"
    },
    "agarwood_info": {
      "age_years": 15,
      "species": "白木香",
      "formation_method": "天然结香",
      "harvest_date": "2025-10"
    },
    "craftsmanship": {
      "artisan": "李师傅",
      "technique": "传统手工打磨",
      "completion_date": "2025-12"
    },
    "certificates": [
      {
        "type": "材质鉴定证书",
        "issuer": "海南省沉香协会",
        "issued_at": "2025-12-15",
        "certificate_url": "https://storage.agarvibe.com/certs/cert_001.pdf"
      }
    ],
    "blockchain_records": [
      {
        "action": "mint",
        "tx_hash": "0xMintTxHash...",
        "timestamp": "2026-03-15T10:00:00Z",
        "details": "NFT 铸造上链"
      }
    ]
  }
}
```

### 6.5 转移 NFT

```http
POST /api/v1/nfts/:token_id/transfer
Authorization: Bearer {jwt_token}
Content-Type: application/json

// Request
{
  "to_address": "0xRecipientAddress...",
  "message": "赠送给好友的祝福"  // 可选
}

// Response (202 Accepted)
{
  "code": 0,
  "message": "转移交易已提交",
  "data": {
    "task_id": "transfer_task_001",
    "estimated_seconds": 30,
    "tx_hash": null
  }
}
```

---

## 7. 市场服务 API

### 7.1 获取商品列表

```http
GET /api/v1/market/products?category=collector&element=木&page=1
Authorization: Bearer {jwt_token}

// Query Parameters
// - category: standard/collector/custom (可选)
// - element: 金/木/水/火/土 (可选)
// - price_min: 最低价格 (可选)
// - price_max: 最高价格 (可选)
// - sort: price_asc/price_desc/popular/newest (可选)

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": [
    {
      "product_id": "prod-001",
      "sku": "AGAR-COL-WOOD-001",
      "name": "海南沉香·木韵",
      "description": "源自海南岛的千年沉香...",
      "category": "collector",
      "five_element": "木",
      "price_cents": 99000,
      "currency": "USD",
      "stock_quantity": 10,
      "sold_count": 25,
      "images": [
        "https://storage.agarvibe.com/products/prod_001_1.jpg"
      ],
      "status": "onsale"
    }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "per_page": 20,
      "total": 50,
      "total_pages": 3
    }
  }
}
```

### 7.2 创建订单

```http
POST /api/v1/market/orders
Authorization: Bearer {jwt_token}
Content-Type: application/json

// Request
{
  "product_id": "prod-001",
  "payment_method": "stripe",  // stripe/paypal/crypto
  "shipping_address": {
    "name": "张三",
    "phone": "+8613800138000",
    "country": "中国",
    "province": "广东省",
    "city": "深圳市",
    "district": "南山区",
    "address": "某某街道某某号",
    "postal_code": "518000"
  }
}

// Response (201 Created)
{
  "code": 0,
  "message": "success",
  "data": {
    "order_id": "order-001",
    "order_no": "ORD202603180001",
    "total_cents": 99000,
    "platform_fee_cents": 4950,
    "payment_method": "stripe",
    "status": "pending",
    "expires_at": "2026-03-18T11:00:00Z"
  }
}
```

### 7.3 确认支付

```http
POST /api/v1/market/orders/:order_id/pay
Authorization: Bearer {jwt_token}
Content-Type: application/json

// Request (加密货币支付)
{
  "crypto_currency": "BNB",
  "tx_hash": "0xPaymentTxHash..."
}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": {
    "order_id": "order-001",
    "status": "paid",
    "paid_at": "2026-03-18T10:35:00Z"
  }
}
```

### 7.4 二手市场上架

```http
POST /api/v1/market/listings
Authorization: Bearer {jwt_token}
Content-Type: application/json

// Request
{
  "bracelet_id": "660e8400-e29b-41d4-a716-446655440001",
  "price_cents": 80000,
  "min_price_cents": 75000,  // 可选，最低接受价
  "listing_type": "fixed",   // fixed/auction
  "duration_days": 30,
  "description": "佩戴了 3 个月，因个人原因转让..."
}

// Response (201 Created)
{
  "code": 0,
  "message": "success",
  "data": {
    "listing_id": "listing-001",
    "status": "active",
    "expires_at": "2026-04-17T10:30:00Z"
  }
}
```

---

## 8. 支付服务 API

### 8.1 创建 Stripe 支付意图

```http
POST /api/v1/payments/stripe/intent
Authorization: Bearer {jwt_token}
Content-Type: application/json

// Request
{
  "order_id": "order-001",
  "currency": "USD"
}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": {
    "client_secret": "pi_xxx_secret_xxx",
    "payment_intent_id": "pi_xxx",
    "amount_cents": 99000,
    "currency": "USD"
  }
}
```

### 8.2 Stripe Webhook 回调

```http
POST /api/v1/payments/stripe/webhook
Stripe-Signature: t=xxx,v1=xxx

// Request (Stripe 发送)
{
  "type": "payment_intent.succeeded",
  "data": {
    "object": {
      "id": "pi_xxx",
      "amount": 99000,
      "metadata": {
        "order_id": "order-001"
      }
    }
  }
}

// Response (200 OK)
{
  "code": 0,
  "message": "success"
}
```

### 8.3 获取加密货币报价

```http
POST /api/v1/payments/crypto/quote
Authorization: Bearer {jwt_token}
Content-Type: application/json

// Request
{
  "amount_cents": 99000,
  "currency": "USD",
  "crypto_currency": "BNB"  // BNB/BUSD/ETH
}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": {
    "fiat_amount": 990.00,
    "fiat_currency": "USD",
    "crypto_amount": 1.2345,
    "crypto_currency": "BNB",
    "exchange_rate": 801.94,
    "gas_fee_estimate_cents": 50,
    "quote_expires_at": "2026-03-18T10:35:00Z"
  }
}
```

---

## 9. AI 服务 API

### 9.1 生成记忆摘要

```http
POST /api/v1/ai/memory/summary
Authorization: Bearer {jwt_token}
Content-Type: application/json
X-API-Key: {internal_service_key}  // 内部服务调用

// Request
{
  "memory_id": "64f5a1b2c3d4e5f6a7b8c9d0",
  "content": "今天在巴黎塞纳河畔冥想，感受着秋日的微风...",
  "element": "木",
  "time": "2026-03-18T10:00:00Z",
  "location": "巴黎塞纳河畔",
  "weather": "晴朗"
}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": {
    "summary": "秋天的第一次冥想，木火相生，能量满满",
    "model": "gpt-4",
    "tokens_used": 150,
    "generated_at": "2026-03-18T10:30:05Z"
  }
}
```

### 9.2 五行 AI 对话 (流式 SSE)

```http
POST /api/v1/ai/chat
Authorization: Bearer {jwt_token}
Content-Type: application/json
Accept: text/event-stream

// Request
{
  "message": "今天适合佩戴我的手串吗？",
  "context": {
    "user_element": "木",
    "bracelet_element": "木",
    "bracelet_id": "660e8400-e29b-41d4-a716-446655440001"
  }
}

// Response (SSE Stream)
data: 根

data: 据

data: 您

data: 的

data: 五

data: 行

data: ...

data: [DONE]
```

### 9.3 生成今日运势

```http
POST /api/v1/ai/fortune/daily
Authorization: Bearer {jwt_token}
Content-Type: application/json

// Request
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "element": "木"
}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": {
    "date": "2026-03-18",
    "fortune": "吉",
    "score": 85,
    "description": "木火相生，利於創作與發展，宜佩戴沉香以安神。",
    "lucky_direction": "东方",
    "lucky_color": "青绿色",
    "advice": "今日适合冥想和创作，佩戴沉香手串可助您静心凝神。"
  }
}
```

### 9.4 智能场景感知推荐

```http
POST /api/v1/ai/scenario/suggest
Authorization: Bearer {jwt_token}
Content-Type: application/json

// Request
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "current_location": {
    "lat": 48.8566,
    "lng": 2.3522,
    "name": "卢浮宫"
  },
  "time": "2026-03-18T14:00:00Z",
  "wearing_bracelet": true
}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": {
    "should_remind": true,
    "reason": "检测到您在博物馆参观，这是一个值得记录的文化体验时刻",
    "suggested_content": "在卢浮宫感受艺术与自然能量的交融",
    "notification_text": "此刻正是记录美好时光的绝佳时刻，要为您的手串留下今天的记忆吗？"
  }
}
```

### 9.5 与手串对话

```http
POST /api/v1/ai/bracelet/talk
Authorization: Bearer {jwt_token}
Content-Type: application/json

// Request
{
  "bracelet_id": "660e8400-e29b-41d4-a716-446655440001",
  "question": "讲讲我的第一次佩戴故事",
  "voice_input": "base64_encoded_audio_data"  // 可选，语音输入
}

// Response (200 OK)
{
  "code": 0,
  "message": "success",
  "data": {
    "answer": "记得那是 3 月 15 日，您第一次佩戴我踏上旅程。那天阳光明媚，木气旺盛...",
    "related_memories": [
      {
        "memory_id": "64f5a1b2c3d4e5f6a7b8c9d0",
        "preview": "第一次佩戴，感觉格外宁静..."
      }
    ],
    "model": "gpt-4",
    "tokens_used": 200
  }
}
```

---

## 10. WebSocket 接口

### 10.1 连接建立

```javascript
// 客户端连接
const ws = new WebSocket('wss://api.agarvibe.com/ws', {
  headers: {
    'Authorization': `Bearer ${jwt_token}`,
    'X-Client-Version': '1.0.0'
  }
});

ws.onopen = () => {
  console.log('WebSocket connected');
  
  // 订阅主题
  ws.send(JSON.stringify({
    action: 'subscribe',
    channels: ['notifications', 'nft_events', 'payment_status']
  }));
};
```

### 10.2 消息格式

```javascript
// 服务端推送消息
{
  type: 'notification',
  channel: 'notifications',
  data: {
    notification_type: 'memory_ai_ready',
    title: 'AI 摘要已生成',
    content: '您的记忆已生成精彩描述，快来看看吧！',
    link: '/memories/64f5a1b2c3d4e5f6a7b8c9d0',
    created_at: '2026-03-18T10:30:05Z'
  }
}

// NFT 事件推送
{
  type: 'nft_event',
  channel: 'nft_events',
  data: {
    event_type: 'mint_completed',
    token_id: 2026031500001,
    tx_hash: '0xMintTxHash...',
    status: 'success'
  }
}

// 支付状态推送
{
  type: 'payment_status',
  channel: 'payment_status',
  data: {
    order_id: 'order-001',
    status: 'completed',
    paid_at: '2026-03-18T10:35:00Z'
  }
}
```

---

## 11. 内部 gRPC 接口

### 11.1 AI 服务 gRPC 定义

```protobuf
syntax = "proto3";
package ai;

service AIService {
  rpc GenerateMemorySummary(MemorySummaryRequest) returns (MemorySummaryResponse);
  rpc ChatStream(ChatRequest) returns (stream ChatResponse);
  rpc GenerateFortune(FortuneRequest) returns (FortuneResponse);
  rpc ScenarioSuggest(ScenarioRequest) returns (ScenarioResponse);
}

message MemorySummaryRequest {
  string memory_id = 1;
  string content = 2;
  string element = 3;
  string time = 4;
  string location = 5;
}

message MemorySummaryResponse {
  string summary = 1;
  string model = 2;
  int32 tokens_used = 3;
}

message ChatRequest {
  string user_id = 1;
  string message = 2;
  ChatContext context = 3;
}

message ChatContext {
  string user_element = 1;
  string bracelet_element = 2;
  repeated Memory memories = 3;
}

message ChatResponse {
  string content = 1;
  bool is_final = 2;
}

message FortuneRequest {
  string user_id = 1;
  string element = 2;
  string date = 3;
}

message FortuneResponse {
  string fortune = 1;
  int32 score = 2;
  string description = 3;
  string advice = 4;
}

message ScenarioRequest {
  string user_id = 1;
  Location location = 2;
  string time = 3;
}

message Location {
  double lat = 1;
  double lng = 2;
  string name = 3;
}

message ScenarioResponse {
  bool should_remind = 1;
  string reason = 2;
  string suggested_content = 3;
}
```

---

## 12. 速率限制

### 12.1 默认限流策略

| 端点类型 | 限流 (次/分钟) | 说明 |
|----------|----------------|------|
| 认证相关 | 10 | 防止暴力破解 |
| 普通查询 | 100 | 一般业务接口 |
| 写操作 | 30 | 创建/更新/删除 |
| AI 对话 | 20 | LLM API 成本考虑 |
| 文件上传 | 10 | 存储成本考虑 |
| WebSocket | 60 | 消息推送频率 |

### 12.2 限流响应

```http
HTTP/1.1 429 Too Many Requests
Retry-After: 60
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1710756060

{
  "code": 1005,
  "message": "请求频率超限，请稍后重试",
  "retry_after": 60
}
```

---

## 13. API 版本管理

### 13.1 版本策略

- URL 路径版本化：`/api/v1/...`, `/api/v2/...`
- 每个大版本维护至少 12 个月
- 弃用提前 3 个月通知
- 向后兼容的变更不升级版本号

### 13.2 弃用流程

```
1. 标记 @Deprecated(since="v1", removeAt="2027-03-18")
2. 响应头添加 Deprecation: true, Sunset: 2027-03-18
3. 文档标注【已弃用】
4. 到期后移除或返回 410 Gone
```

---

**文档维护**: 本 API 规范应随功能迭代持续更新，所有 API 变更需经过技术评审。完整的 OpenAPI 3.0 规范文件位于 `../specs/openapi.yaml`。
