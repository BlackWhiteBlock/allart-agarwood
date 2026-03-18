# 众艺链海南 AI 沉香手串 - 数据库 Schema 设计文档

**版本**: 1.0  
**日期**: 2026 年 3 月  
**数据库**: PostgreSQL 15 + MongoDB 7 + Redis 7

---

## 1. 数据库选型说明

### 1.1 多数据库架构

| 数据类型 | 数据库 | 选型理由 |
|----------|--------|----------|
| 用户/交易/订单/设备 | PostgreSQL | 强一致性、事务支持、关系型数据 |
| 记忆/社群动态/评论 | MongoDB | 非结构化文档、灵活 Schema、水平扩展 |
| 会话/缓存/排行榜 | Redis | 高性能、丰富数据结构、发布订阅 |
| 区块链数据 | PostgreSQL + 链上同步 | 混合存储（元数据 PG，原始数据链上） |
| 搜索索引 | Elasticsearch | 全文检索、复杂查询 |

### 1.2 数据库连接配置

```yaml
# PostgreSQL
postgresql:
  host: pg-cluster.agarvibe.internal
  port: 5432
  database: agarvibe_main
  user: agarvibe_app
  pool_size: 20
  max_overflow: 10
  ssl_mode: require

# MongoDB
mongodb:
  uri: mongodb://mongo-cluster.agarvibe.internal:27017
  database: agarvibe_docs
  replica_set: rs0
  pool_size: 50

# Redis
redis:
  host: redis-cluster.agarvibe.internal
  port: 6379
  password: ${REDIS_PASSWORD}
  db: 0
  pool_size: 30
```

---

## 2. PostgreSQL Schema

### 2.1 用户域 (User Domain)

#### 2.1.1 users - 用户基础表

```sql
CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone           VARCHAR(20) UNIQUE,                    -- 手机号
    email           VARCHAR(255) UNIQUE,                   -- 邮箱
    password_hash   VARCHAR(255),                          -- 密码哈希 (BCrypt)
    nickname        VARCHAR(50) NOT NULL,                  -- 昵称
    avatar_url      VARCHAR(512),                          -- 头像 URL
    premium_level   VARCHAR(20) DEFAULT 'free',            -- free/premium/vip
    status          VARCHAR(20) DEFAULT 'active',          -- active/suspended/deleted
    kyc_status      VARCHAR(20) DEFAULT 'pending',         -- pending/approved/rejected
    language        VARCHAR(10) DEFAULT 'zh-TW',           -- 语言偏好
    timezone        VARCHAR(50) DEFAULT 'Asia/Shanghai',   -- 时区
    
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,                           -- 软删除标记
    
    CONSTRAINT chk_users_contact CHECK (phone IS NOT NULL OR email IS NOT NULL),
    CONSTRAINT chk_users_premium CHECK (premium_level IN ('free', 'premium', 'vip'))
);

-- 索引
CREATE INDEX idx_users_phone ON users(phone) WHERE phone IS NOT NULL;
CREATE INDEX idx_users_email ON users(email) WHERE email IS NOT NULL;
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_at ON users(created_at DESC);
CREATE INDEX idx_users_deleted_at ON users(deleted_at) WHERE deleted_at IS NOT NULL;

-- 注释
COMMENT ON TABLE users IS '用户基础信息表';
COMMENT ON COLUMN users.premium_level IS '会员等级：free-免费，premium-高级，vip-至尊';
```

#### 2.1.2 user_wallets - 用户钱包表

```sql
CREATE TABLE user_wallets (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    wallet_address  VARCHAR(42) NOT NULL,                  -- BSC 地址 (0x 开头)
    chain_id        INTEGER NOT NULL DEFAULT 56,           -- 56=BSC Mainnet, 97=BSC Testnet
    is_primary      BOOLEAN NOT NULL DEFAULT true,         -- 是否主钱包
    bound_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_used_at    TIMESTAMPTZ,
    
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT uk_user_wallet UNIQUE(user_id, wallet_address),
    CONSTRAINT chk_wallet_address CHECK (wallet_address ~ '^0x[a-fA-F0-9]{40}$')
);

-- 索引
CREATE INDEX idx_user_wallets_user_id ON user_wallets(user_id);
CREATE INDEX idx_user_wallets_address ON user_wallets(wallet_address);
CREATE INDEX idx_user_wallets_chain ON user_wallets(chain_id);

-- 注释
COMMENT ON TABLE user_wallets IS '用户钱包绑定表';
```

#### 2.1.3 user_preferences - 用户偏好表

```sql
CREATE TABLE user_preferences (
    user_id         UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    theme_style     VARCHAR(30) DEFAULT 'oriental_minimal', -- oriental_minimal/cyber_future
    notifications   JSONB NOT NULL DEFAULT '{}',           -- 通知偏好
    privacy_settings JSONB NOT NULL DEFAULT '{}',          -- 隐私设置
    five_elements   JSONB,                                  -- 五行属性 (可选)
    bazi_info       JSONB,                                  -- 八字信息 (可选)
    
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 注释
COMMENT ON TABLE user_preferences IS '用户偏好设置表';
COMMENT ON COLUMN user_preferences.notifications IS '通知设置：{"push_enabled": true, "email_enabled": false, ...}';
COMMENT ON COLUMN user_preferences.privacy_settings IS '隐私设置：{"show_profile": true, "show_memories": false, ...}';
```

#### 2.1.4 kyc_records - KYC 记录表

```sql
CREATE TABLE kyc_records (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    document_type   VARCHAR(30) NOT NULL,                  -- id_card/passport/drivers_license
    document_front  VARCHAR(512) NOT NULL,                 -- 正面照片 URL
    document_back   VARCHAR(512),                          -- 反面照片 URL (身份证需要)
    selfie_url      VARCHAR(512),                          -- 手持证件照 URL
    real_name       VARCHAR(100),                          -- 真实姓名
    id_number       VARCHAR(50),                           -- 身份证号/护照号 (加密存储)
    
    status          VARCHAR(20) NOT NULL DEFAULT 'pending', -- pending/reviewing/approved/rejected
    review_comment  TEXT,                                   -- 审核意见
    reviewed_by     UUID,                                   -- 审核员 ID
    reviewed_at     TIMESTAMPTZ,
    
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT chk_kyc_status CHECK (status IN ('pending', 'reviewing', 'approved', 'rejected'))
);

-- 索引
CREATE INDEX idx_kyc_records_user_id ON kyc_records(user_id);
CREATE INDEX idx_kyc_records_status ON kyc_records(status);

-- 注释
COMMENT ON TABLE kyc_records IS 'KYC 认证记录表';
```

---

### 2.2 设备域 (Device Domain)

#### 2.2.1 nfc_chips - NFC 芯片表

```sql
CREATE TABLE nfc_chips (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chip_id         VARCHAR(64) UNIQUE NOT NULL,           -- NFC 芯片唯一 ID
    manufacturer    VARCHAR(50) NOT NULL,                  -- 厂商
    model           VARCHAR(50),                            -- 型号
    production_batch VARCHAR(50),                           -- 生产批次
    
    status          VARCHAR(20) DEFAULT 'unused',          -- unused/bound/disabled
    activated_at    TIMESTAMPTZ,                            -- 激活时间
    
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT chk_chip_status CHECK (status IN ('unused', 'bound', 'disabled'))
);

-- 索引
CREATE INDEX idx_nfc_chips_chip_id ON nfc_chips(chip_id);
CREATE INDEX idx_nfc_chips_status ON nfc_chips(status);

-- 注释
COMMENT ON TABLE nfc_chips IS 'NFC 芯片信息表';
```

#### 2.2.2 bracelets - 手串信息表

```sql
CREATE TABLE bracelets (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nfc_chip_id     UUID UNIQUE REFERENCES nfc_chips(id),
    
    name            VARCHAR(100) NOT NULL,                 -- 手串名称
    five_element    VARCHAR(10) NOT NULL,                  -- 五行属性：金/木/水/火/土
    material        VARCHAR(200),                          -- 材质描述
    origin_lat      DECIMAL(10, 8),                        -- 产地纬度
    origin_lng      DECIMAL(11, 8),                        -- 产地经度
    origin_address  VARCHAR(500),                          -- 产地地址
    
    agarwood_age    INTEGER,                               -- 结香年份
    bead_count      INTEGER,                               -- 珠子数量
    weight_grams    DECIMAL(8, 2),                         -- 重量 (克)
    
    category        VARCHAR(30) DEFAULT 'standard',        -- standard/collector/custom
    price_cents     INTEGER,                               -- 售价 (分，USD)
    
    nft_token_id    BIGINT,                                -- NFT Token ID (铸造后填写)
    nft_contract    VARCHAR(42),                           -- NFT 合约地址
    
    status          VARCHAR(20) DEFAULT 'available',       -- available/sold/reserved
    
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT chk_element CHECK (five_element IN ('金', '木', '水', '火', '土')),
    CONSTRAINT chk_category CHECK (category IN ('standard', 'collector', 'custom')),
    CONSTRAINT chk_price CHECK (price_cents >= 0)
);

-- 索引
CREATE INDEX idx_bracelets_nfc_chip_id ON bracelets(nfc_chip_id);
CREATE INDEX idx_bracelets_element ON bracelets(five_element);
CREATE INDEX idx_bracelets_category ON bracelets(category);
CREATE INDEX idx_bracelets_status ON bracelets(status);
CREATE INDEX idx_bracelets_nft_token ON bracelets(nft_token_id) WHERE nft_token_id IS NOT NULL;

-- 注释
COMMENT ON TABLE bracelets IS '手串信息表';
COMMENT ON COLUMN bracelets.five_element IS '五行属性：金、木、水、火、土';
COMMENT ON COLUMN bracelets.category IS '商品分类：standard-入门款，collector-收藏款，custom-定制款';
```

#### 2.2.3 device_bindings - 设备绑定关系表

```sql
CREATE TABLE device_bindings (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    bracelet_id     UUID NOT NULL REFERENCES bracelets(id) ON DELETE CASCADE,
    
    nickname        VARCHAR(50),                            -- 用户自定义昵称
    bound_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    unbound_at      TIMESTAMPTZ,                            -- 解绑时间
    
    status          VARCHAR(20) DEFAULT 'active',          -- active/inactive
    
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT uk_user_bracelet UNIQUE(user_id, bracelet_id),
    CONSTRAINT chk_binding_status CHECK (status IN ('active', 'inactive'))
);

-- 索引
CREATE INDEX idx_device_bindings_user_id ON device_bindings(user_id);
CREATE INDEX idx_device_bindings_bracelet_id ON device_bindings(bracelet_id);
CREATE INDEX idx_device_bindings_status ON device_bindings(status);

-- 注释
COMMENT ON TABLE device_bindings IS '用户 - 手串绑定关系表';
```

#### 2.2.4 nfc_interaction_logs - NFC 交互日志表

```sql
CREATE TABLE nfc_interaction_logs (
    id              BIGSERIAL PRIMARY KEY,
    binding_id      UUID REFERENCES device_bindings(id),
    user_id         UUID NOT NULL REFERENCES users(id),
    bracelet_id     UUID NOT NULL REFERENCES bracelets(id),
    
    action          VARCHAR(50) NOT NULL,                  -- scan/read/write
    result          VARCHAR(20) NOT NULL,                  -- success/failed/timeout
    error_message   TEXT,
    duration_ms     INTEGER,                               -- 耗时 (毫秒)
    
    device_model    VARCHAR(100),                          -- 手机型号
    os_version      VARCHAR(50),                           -- 系统版本
    app_version     VARCHAR(20),                           -- App 版本
    
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_nfc_logs_user_id ON nfc_interaction_logs(user_id);
CREATE INDEX idx_nfc_logs_bracelet_id ON nfc_interaction_logs(bracelet_id);
CREATE INDEX idx_nfc_logs_created_at ON nfc_interaction_logs(created_at DESC);
CREATE INDEX idx_nfc_logs_result ON nfc_interaction_logs(result);

-- 注释
COMMENT ON TABLE nfc_interaction_logs IS 'NFC 交互日志表';
```

---

### 2.3 记忆域 (Memory Domain)

> **注意**: 记忆的主要内容存储在 MongoDB，PostgreSQL 仅存储索引和元数据

#### 2.3.1 memory_indices - 记忆索引表 (PostgreSQL)

```sql
CREATE TABLE memory_indices (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL,
    bracelet_id     UUID NOT NULL,
    
    content_preview VARCHAR(500),                          -- 内容预览 (前 500 字符)
    media_type      VARCHAR(20) DEFAULT 'text',            -- text/photo/audio/video
    media_count     INTEGER DEFAULT 0,                     -- 媒体文件数量
    
    location_name   VARCHAR(200),                          -- 地点名称
    location_lat    DECIMAL(10, 8),                        -- 纬度
    location_lng    DECIMAL(11, 8),                        -- 经度
    
    tags            TEXT[],                                -- 标签数组
    privacy         VARCHAR(20) DEFAULT 'private',         -- private/friends/public
    
    ai_summary      VARCHAR(500),                          -- AI 生成的摘要
    
    is_favorite     BOOLEAN DEFAULT false,
    is_deleted      BOOLEAN DEFAULT false,
    
    memory_date     TIMESTAMPTZ NOT NULL,                  -- 记忆发生时间
    mongo_id        VARCHAR(24),                           -- MongoDB 中的 ObjectId
    
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT chk_memory_type CHECK (media_type IN ('text', 'photo', 'audio', 'video')),
    CONSTRAINT chk_privacy CHECK (privacy IN ('private', 'friends', 'public'))
);

-- 索引
CREATE INDEX idx_memory_indices_user_id ON memory_indices(user_id);
CREATE INDEX idx_memory_indices_bracelet_id ON memory_indices(bracelet_id);
CREATE INDEX idx_memory_indices_memory_date ON memory_indices(memory_date DESC);
CREATE INDEX idx_memory_indices_tags ON memory_indices USING GIN(tags);
CREATE INDEX idx_memory_indices_privacy ON memory_indices(privacy);
CREATE INDEX idx_memory_indices_location ON memory_indices(location_lat, location_lng);
CREATE INDEX idx_memory_indices_mongo_id ON memory_indices(mongo_id);

-- 注释
COMMENT ON TABLE memory_indices IS '记忆索引表 (PostgreSQL 元数据，实际内容在 MongoDB)';
```

---

### 2.4 NFT 域 (NFT Domain)

#### 2.4.1 nft_tokens - NFT Token 表

```sql
CREATE TABLE nft_tokens (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bracelet_id     UUID UNIQUE REFERENCES bracelets(id),
    
    token_id        BIGINT NOT NULL,                       -- ERC721 Token ID
    contract_address VARCHAR(42) NOT NULL,                 -- 合约地址
    chain_id        INTEGER NOT NULL DEFAULT 56,           -- 链 ID
    
    owner_address   VARCHAR(42) NOT NULL,                  -- 当前持有者地址
    original_owner  VARCHAR(42) NOT NULL,                  -- 初始所有者 (铸造者)
    
    metadata_uri    VARCHAR(512),                          -- IPFS URI
    metadata_hash   VARCHAR(64),                           -- 元数据哈希
    
    -- 元数据解析字段 (冗余存储，方便查询)
    name            VARCHAR(200),
    description     TEXT,
    image_url       VARCHAR(512),
    attributes      JSONB,                                 -- 属性 (五行、材质等)
    
    mint_tx_hash    VARCHAR(66),                           -- 铸造交易哈希
    minted_at       TIMESTAMPTZ,
    
    status          VARCHAR(20) DEFAULT 'active',          -- active/transferring/burned
    
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT chk_nft_status CHECK (status IN ('active', 'transferring', 'burned')),
    CONSTRAINT chk_contract_address CHECK (contract_address ~ '^0x[a-fA-F0-9]{40}$'),
    CONSTRAINT chk_owner_address CHECK (owner_address ~ '^0x[a-fA-F0-9]{40}$')
);

-- 索引
CREATE INDEX idx_nft_tokens_token_id ON nft_tokens(token_id, chain_id);
CREATE INDEX idx_nft_tokens_contract ON nft_tokens(contract_address);
CREATE INDEX idx_nft_tokens_owner ON nft_tokens(owner_address);
CREATE INDEX idx_nft_tokens_bracelet_id ON nft_tokens(bracelet_id);

-- 注释
COMMENT ON TABLE nft_tokens IS 'NFT Token 信息表';
COMMENT ON COLUMN nft_tokens.metadata_uri IS 'IPFS URI，格式如：ipfs://QmXxx...';
COMMENT ON COLUMN nft_tokens.attributes IS 'NFT 属性 JSON，例：{"element":"木","age":15,"origin":"海南"}';
```

#### 2.4.2 nft_transfer_history - NFT 流转历史表

```sql
CREATE TABLE nft_transfer_history (
    id              BIGSERIAL PRIMARY KEY,
    token_id        BIGINT NOT NULL,
    contract_address VARCHAR(42) NOT NULL,
    
    from_address    VARCHAR(42) NOT NULL,
    to_address      VARCHAR(42) NOT NULL,
    
    tx_hash         VARCHAR(66) NOT NULL,
    block_number    BIGINT NOT NULL,
    block_timestamp TIMESTAMPTZ NOT NULL,
    
    transfer_type   VARCHAR(30) NOT NULL,                -- mint/transfer/burn
    price_cents     INTEGER,                              -- 交易价格 (如果是销售)
    
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_nft_history_token ON nft_transfer_history(token_id, contract_address);
CREATE INDEX idx_nft_history_tx_hash ON nft_transfer_history(tx_hash);
CREATE INDEX idx_nft_history_block ON nft_transfer_history(block_number);
CREATE INDEX idx_nft_history_from ON nft_transfer_history(from_address);
CREATE INDEX idx_nft_history_to ON nft_transfer_history(to_address);

-- 注释
COMMENT ON TABLE nft_transfer_history IS 'NFT 流转历史表';
```

#### 2.4.3 dividend_records - 分红记录表

```sql
CREATE TABLE dividend_records (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token_id        BIGINT NOT NULL,
    contract_address VARCHAR(42) NOT NULL,
    
    sale_price_cents INTEGER NOT NULL,                    -- 销售价格
    dividend_rate   DECIMAL(5, 4) NOT NULL DEFAULT 0.03,  -- 分红比例 (默认 3%)
    dividend_amount_cents INTEGER NOT NULL,               -- 分红金额
    
    recipient_address VARCHAR(42) NOT NULL,               -- 接收地址 (原主人)
    tx_hash         VARCHAR(66),                          -- 分红交易哈希
    
    status          VARCHAR(20) DEFAULT 'pending',        -- pending/completed/failed
    
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at    TIMESTAMPTZ,
    
    CONSTRAINT chk_dividend_status CHECK (status IN ('pending', 'completed', 'failed'))
);

-- 索引
CREATE INDEX idx_dividend_records_token ON dividend_records(token_id, contract_address);
CREATE INDEX idx_dividend_records_recipient ON dividend_records(recipient_address);
CREATE INDEX idx_dividend_records_status ON dividend_records(status);

-- 注释
COMMENT ON TABLE dividend_records IS '智能合约分红记录表';
```

---

### 2.5 市场域 (Market Domain)

#### 2.5.1 products - 商品表

```sql
CREATE TABLE products (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku             VARCHAR(50) UNIQUE NOT NULL,           -- 库存单位
    
    name            VARCHAR(200) NOT NULL,
    description     TEXT,
    
    category        VARCHAR(30) NOT NULL,                  -- standard/collector/custom
    five_element    VARCHAR(10),                           -- 五行属性 (可筛选)
    
    price_cents     INTEGER NOT NULL,
    currency        VARCHAR(3) DEFAULT 'USD',
    
    stock_quantity  INTEGER DEFAULT 0,
    sold_count      INTEGER DEFAULT 0,
    
    images          TEXT[] NOT NULL,                       -- 图片 URL 数组
    video_url       VARCHAR(512),                          -- 视频 URL
    
    status          VARCHAR(20) DEFAULT 'onsale',          -- onsale/soldout/discontinued
    
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT chk_product_category CHECK (category IN ('standard', 'collector', 'custom')),
    CONSTRAINT chk_product_status CHECK (status IN ('onsale', 'soldout', 'discontinued')),
    CONSTRAINT chk_price_positive CHECK (price_cents > 0)
);

-- 索引
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_element ON products(five_element);
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_price ON products(price_cents);
CREATE INDEX idx_products_created_at ON products(created_at DESC);

-- 注释
COMMENT ON TABLE products IS '商品表 (一级市场)';
```

#### 2.5.2 orders - 订单表

```sql
CREATE TABLE orders (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_no        VARCHAR(50) UNIQUE NOT NULL,           -- 订单号
    
    user_id         UUID NOT NULL REFERENCES users(id),
    product_id      UUID REFERENCES products(id),
    bracelet_id     UUID REFERENCES bracelets(id),         -- 二级市场时有值
    
    total_cents     INTEGER NOT NULL,
    platform_fee_cents INTEGER DEFAULT 0,                  -- 平台手续费
    payment_method  VARCHAR(30),                           -- stripe/paypal/crypto
    
    status          VARCHAR(30) DEFAULT 'pending',         -- pending/paid/shipping/completed/cancelled/refunded
    
    shipping_address JSONB,
    tracking_number  VARCHAR(100),
    
    paid_at         TIMESTAMPTZ,
    shipped_at      TIMESTAMPTZ,
    completed_at    TIMESTAMPTZ,
    
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT chk_order_status CHECK (status IN ('pending', 'paid', 'shipping', 'completed', 'cancelled', 'refunded'))
);

-- 索引
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_order_no ON orders(order_no);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);

-- 注释
COMMENT ON TABLE orders IS '订单表';
```

#### 2.5.3 listings - 二手市场上架表

```sql
CREATE TABLE listings (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id       UUID NOT NULL REFERENCES users(id),
    bracelet_id     UUID NOT NULL REFERENCES bracelets(id),
    
    price_cents     INTEGER NOT NULL,
    currency        VARCHAR(3) DEFAULT 'USD',
    min_price_cents INTEGER,                               -- 最低接受价 (可选)
    
    listing_type    VARCHAR(20) DEFAULT 'fixed',           -- fixed/auction
    duration_days   INTEGER DEFAULT 30,                    -- 上架天数
    
    status          VARCHAR(20) DEFAULT 'active',          -- active/sold/expired/cancelled
    
    views_count     INTEGER DEFAULT 0,
    favorites_count INTEGER DEFAULT 0,
    
    listed_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at      TIMESTAMPTZ NOT NULL,
    sold_at         TIMESTAMPTZ,
    
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT chk_listing_type CHECK (listing_type IN ('fixed', 'auction')),
    CONSTRAINT chk_listing_status CHECK (status IN ('active', 'sold', 'expired', 'cancelled')),
    CONSTRAINT chk_price_valid CHECK (price_cents > 0 AND (min_price_cents IS NULL OR min_price_cents <= price_cents))
);

-- 索引
CREATE INDEX idx_listings_seller_id ON listings(seller_id);
CREATE INDEX idx_listings_bracelet_id ON listings(bracelet_id);
CREATE INDEX idx_listings_status ON listings(status);
CREATE INDEX idx_listings_price ON listings(price_cents);
CREATE INDEX idx_listings_expires_at ON listings(expires_at);

-- 注释
COMMENT ON TABLE listings IS '二手市场上架表';
```

---

### 2.6 支付域 (Payment Domain)

#### 2.6.1 payments - 支付记录表

```sql
CREATE TABLE payments (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id        UUID NOT NULL REFERENCES orders(id),
    user_id         UUID NOT NULL REFERENCES users(id),
    
    amount_cents    INTEGER NOT NULL,
    currency        VARCHAR(3) NOT NULL,
    exchange_rate   DECIMAL(18, 8),                        -- 法币转加密货币的汇率
    
    payment_method  VARCHAR(30) NOT NULL,                 -- stripe/paypal/bnb/busd
    payment_provider_id VARCHAR(200),                      -- 第三方支付 ID (Stripe Payment Intent ID 等)
    
    crypto_amount   DECIMAL(20, 8),                        -- 加密货币金额
    crypto_currency VARCHAR(20),                           -- BNB/BUSD/ETH
    
    status          VARCHAR(30) DEFAULT 'pending',         -- pending/processing/completed/failed/refunded
    
    tx_hash         VARCHAR(66),                           -- 区块链交易哈希 (加密货币支付)
    gas_fee_cents   INTEGER,                               -- Gas 费用
    
    error_code      VARCHAR(50),
    error_message   TEXT,
    
    paid_at         TIMESTAMPTZ,
    
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    idempotency_key VARCHAR(64) UNIQUE,                    -- 幂等性键
    
    CONSTRAINT chk_payment_status CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'refunded')),
    CONSTRAINT chk_payment_method CHECK (payment_method IN ('stripe', 'paypal', 'bnb', 'busd', 'eth'))
);

-- 索引
CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_provider_id ON payments(payment_provider_id);
CREATE INDEX idx_payments_created_at ON payments(created_at DESC);

-- 注释
COMMENT ON TABLE payments IS '支付记录表';
```

#### 2.6.2 exchange_rates - 汇率表

```sql
CREATE TABLE exchange_rates (
    id              BIGSERIAL PRIMARY KEY,
    base_currency   VARCHAR(3) NOT NULL,                  -- 基础货币 (USD)
    quote_currency  VARCHAR(20) NOT NULL,                 -- 目标货币 (BNB/BUSD/ETH)
    
    rate            DECIMAL(18, 8) NOT NULL,              -- 汇率
    source          VARCHAR(50),                          -- 来源 (binance/coinbase/manual)
    
    effective_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at      TIMESTAMPTZ NOT NULL,
    
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_exchange_rates_pair ON exchange_rates(base_currency, quote_currency, effective_at DESC);

-- 注释
COMMENT ON TABLE exchange_rates IS '汇率表 (法币 - 加密货币)';
```

---

### 2.7 通用表

#### 2.7.1 system_configs - 系统配置表

```sql
CREATE TABLE system_configs (
    key             VARCHAR(100) PRIMARY KEY,
    value           JSONB NOT NULL,
    description     TEXT,
    
    updated_by      UUID,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 注释
COMMENT ON TABLE system_configs IS '系统配置表';
```

#### 2.7.2 api_keys - API 密钥表

```sql
CREATE TABLE api_keys (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_name    VARCHAR(50) NOT NULL,                 -- 服务名称
    key_hash        VARCHAR(64) NOT NULL,                 -- API Key 哈希
    
    scopes          TEXT[] NOT NULL,                      -- 权限范围
    rate_limit      INTEGER DEFAULT 1000,                 -- 每分钟请求限制
    
    last_used_at    TIMESTAMPTZ,
    expires_at      TIMESTAMPTZ,
    
    status          VARCHAR(20) DEFAULT 'active',         -- active/revoked/expired
    
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT chk_api_key_status CHECK (status IN ('active', 'revoked', 'expired'))
);

-- 索引
CREATE INDEX idx_api_keys_service ON api_keys(service_name);
CREATE INDEX idx_api_keys_key_hash ON api_keys(key_hash);

-- 注释
COMMENT ON TABLE api_keys IS 'API 密钥表 (服务间调用)';
```

---

## 3. MongoDB Schema

### 3.1 memories - 记忆文档集合

```javascript
// Database: agarvibe_docs
// Collection: memories

{
  _id: ObjectId("64f5a1b2c3d4e5f6a7b8c9d0"),
  user_id: UUID("550e8400-e29b-41d4-a716-446655440000"),
  bracelet_id: UUID("660e8400-e29b-41d4-a716-446655440001"),
  
  // 内容
  content: "今天在巴黎塞纳河畔冥想，感受着秋日的微风...",
  media_type: "photo",  // text | photo | audio | video
  
  // 媒体文件
  media_urls: [
    "https://storage.agarvibe.com/memories/user_id/20260318_001.jpg",
    "https://storage.agarvibe.com/memories/user_id/20260318_002.jpg"
  ],
  audio_url: null,  // 语音 URL (如果有)
  
  // 地理位置
  location: {
    type: "Point",
    coordinates: [2.3522, 48.8566],  // [lng, lat]
    name: "巴黎塞纳河畔",
    address: "Paris, France",
    country: "France"
  },
  
  // 标签
  tags: ["冥想", "旅行", "秋天", "巴黎"],
  
  // 隐私设置
  privacy: "private",  // private | friends | public
  
  // AI 生成内容
  ai_summary: "秋天的第一次冥想，木火相生，能量满满",
  ai_metadata: {
    model: "gpt-4",
    prompt_version: "v2.1",
    generated_at: ISODate("2026-03-18T10:30:00Z")
  },
  
  // 五行相关
  five_element_context: {
    day_element: "木",
    hour_element: "火",
    weather: "晴朗"
  },
  
  // 状态
  is_favorite: false,
  is_deleted: false,
  deleted_at: null,
  
  // 时间
  memory_date: ISODate("2026-03-18T10:00:00Z"),
  created_at: ISODate("2026-03-18T10:30:00Z"),
  updated_at: ISODate("2026-03-18T10:30:00Z")
}

// 索引
db.memories.createIndex({ user_id: 1, memory_date: -1 });
db.memories.createIndex({ bracelet_id: 1, memory_date: -1 });
db.memories.createIndex({ location: "2dsphere" });  // 地理位置索引
db.memories.createIndex({ tags: 1 });
db.memories.createIndex({ privacy: 1, is_deleted: 1 });
db.memories.createIndex({ memory_date: -1 });
db.memories.createIndex({ user_id: 1, is_favorite: 1 });

// 全文搜索索引 (用于内容搜索)
db.memories.createIndex({ content: "text", tags: "text" });
```

### 3.2 community_posts - 社群动态集合

```javascript
// Database: agarvibe_docs
// Collection: community_posts

{
  _id: ObjectId("64f5a1b2c3d4e5f6a7b8c9d1"),
  user_id: UUID("550e8400-e29b-41d4-a716-446655440000"),
  
  // 内容
  content: "今天佩戴沉香手串参加瑜伽课，感觉格外宁静...",
  media_urls: [
    "https://storage.agarvibe.com/posts/user_id/post_001.jpg"
  ],
  
  // 关联
  related_memory_id: ObjectId("64f5a1b2c3d4e5f6a7b8c9d0"),
  related_bracelet_id: UUID("660e8400-e29b-41d4-a716-446655440001"),
  
  // 互动统计
  likes_count: 42,
  comments_count: 8,
  shares_count: 3,
  views_count: 156,
  
  // 点赞用户列表 (最近 100 个)
  liked_by: [
    { user_id: UUID("..."), liked_at: ISODate("...") }
  ],
  
  // 状态
  is_public: true,
  is_deleted: false,
  
  // 时间
  created_at: ISODate("2026-03-18T11:00:00Z"),
  updated_at: ISODate("2026-03-18T11:00:00Z")
}

// 索引
db.community_posts.createIndex({ user_id: 1, created_at: -1 });
db.community_posts.createIndex({ created_at: -1 });  // 广场 feed 流
db.community_posts.createIndex({ likes_count: -1 });  // 热门排序
db.community_posts.createIndex({ is_public: 1, is_deleted: 1, created_at: -1 });
```

### 3.3 community_comments - 社群评论集合

```javascript
// Database: agarvibe_docs
// Collection: community_comments

{
  _id: ObjectId("64f5a1b2c3d4e5f6a7b8c9d2"),
  post_id: ObjectId("64f5a1b2c3d4e5f6a7b8c9d1"),
  user_id: UUID("550e8400-e29b-41d4-a716-446655440000"),
  parent_comment_id: ObjectId("64f5a1b2c3d4e5f6a7b8c9d3"),  // 回复评论时有值
  
  content: "说得真好！我也想去试试",
  
  likes_count: 5,
  is_deleted: false,
  
  created_at: ISODate("2026-03-18T11:30:00Z"),
  updated_at: ISODate("2026-03-18T11:30:00Z")
}

// 索引
db.community_comments.createIndex({ post_id: 1, created_at: -1 });
db.community_comments.createIndex({ parent_comment_id: 1 });
```

### 3.4 ai_chat_sessions - AI 对话会话集合

```javascript
// Database: agarvibe_docs
// Collection: ai_chat_sessions

{
  _id: ObjectId("64f5a1b2c3d4e5f6a7b8c9d4"),
  user_id: UUID("550e8400-e29b-41d4-a716-446655440000"),
  bracelet_id: UUID("660e8400-e29b-41d4-a716-446655440001"),
  
  // 会话上下文
  context: {
    user_element: "木",
    bracelet_element: "木",
    user_bazi: { year: "木", month: "火", day: "土", hour: "金" }
  },
  
  // 对话历史 (最近 50 轮)
  messages: [
    {
      role: "user",  // user | assistant | system
      content: "今天适合佩戴我的手串吗？",
      timestamp: ISODate("2026-03-18T12:00:00Z")
    },
    {
      role: "assistant",
      content: "根据您的五行属性，今日木火相生，非常适合佩戴...",
      metadata: {
        model: "gpt-4",
        tokens_used: 150
      },
      timestamp: ISODate("2026-03-18T12:00:01Z")
    }
  ],
  
  // 统计
  total_messages: 2,
  
  created_at: ISODate("2026-03-18T12:00:00Z"),
  updated_at: ISODate("2026-03-18T12:00:01Z"),
  expires_at: ISODate("2026-04-18T12:00:00Z")  // 30 天后过期
}

// 索引
db.ai_chat_sessions.createIndex({ user_id: 1, updated_at: -1 });
db.ai_chat_sessions.createIndex({ expires_at: 1 }, { expireAfterSeconds: 0 });  // TTL 索引
```

---

## 4. Redis 数据结构设计

### 4.1 Session 管理

```redis
# Key 格式：session:{session_id}
# Value: Hash
HSET session:abc123 \
  user_id "550e8400-e29b-41d4-a716-446655440000" \
  wallet_address "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb" \
  created_at "1710756000" \
  expires_at "1710842400"

EXPIRE session:abc123 86400  # 24 小时过期
```

### 4.2 JWT Token 黑名单

```redis
# Key 格式：token:blacklist:{jti}
# Value: String (过期时间戳)
SETEX token:blacklist:jti_abc123 3600 "1710759600"
```

### 4.3 NFC 芯片验证缓存

```redis
# Key 格式：nfc:chip:{chip_id}
# Value: Hash
HSET nfc:chip:NFC001 \
  status "bound" \
  bracelet_id "660e8400-e29b-41d4-a716-446655440001" \
  verified_at "1710756000"

EXPIRE nfc:chip:NFC001 300  # 5 分钟缓存
```

### 4.4 用户资料缓存

```redis
# Key 格式：user:profile:{user_id}
# Value: Hash (JSON 字符串)
SETEX user:profile:550e8400-e29b-41d4-a716-446655440000 1800 '{"id":"...","nickname":"..."}'
```

### 4.5 今日运势缓存

```redis
# Key 格式：fortune:daily:{user_id}:{date}
# Value: String (JSON)
SETEX fortune:daily:550e8400-e29b-41d4-a716-446655440000:2026-03-18 86400 \
  '{"element":"木","fortune":"吉","advice":"佩戴沉香静心"}'
```

### 4.6 五行能量实时排行

```redis
# Sorted Set: leaderboard:five_elements:{element}
# Score: 能量值，Member: user_id
ZADD leaderboard:five_elements:木 85 "550e8400-e29b-41d4-a716-446655440000"
ZADD leaderboard:five_elements:木 92 "660e8400-e29b-41d4-a716-446655440001"

# 获取 Top 10
ZREVRANGE leaderboard:five_elements:木 0 9 WITHSCORES
```

### 4.7 分布式锁

```redis
# Key 格式：lock:{resource_name}
# Value: UUID (防止误删)
SET lock:order:create:550e8400-e29b-41d4-a716-446655440000 \
    "uuid-abc-123" NX PX 5000  # 5 秒超时
```

### 4.8 消息队列 (NATS 为主，Redis 备用)

```redis
# List: queue:{queue_name}
LPUSH queue:memory:ai_generate '{"memory_id":"...","user_id":"..."}'
RPOP queue:memory:ai_generate  # 阻塞式消费
```

---

## 5. Elasticsearch 索引设计

### 5.1 memories 索引 (记忆搜索)

```json
PUT /memories
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 1,
    "analysis": {
      "analyzer": {
        "chinese_analyzer": {
          "type": "smartcn"
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "memory_id": { "type": "keyword" },
      "user_id": { "type": "keyword" },
      "bracelet_id": { "type": "keyword" },
      "content": {
        "type": "text",
        "analyzer": "chinese_analyzer"
      },
      "ai_summary": {
        "type": "text",
        "analyzer": "chinese_analyzer"
      },
      "tags": { "type": "keyword" },
      "location_name": {
        "type": "text",
        "fields": {
          "keyword": { "type": "keyword" }
        }
      },
      "location": { "type": "geo_point" },
      "privacy": { "type": "keyword" },
      "memory_date": { "type": "date" },
      "created_at": { "type": "date" }
    }
  }
}
```

---

## 6. 数据同步策略

### 6.1 PostgreSQL ↔ Elasticsearch

**工具**: Logstash / Debezium + Kafka Connect

```yaml
# Logstash 管道配置示例
input {
  jdbc {
    jdbc_connection_string => "jdbc:postgresql://pg/agarvibe_main"
    jdbc_user => "agarvibe_app"
    schedule => "* * * * *"  # 每分钟同步
    statement => """
      SELECT id, user_id, content, ai_summary, tags, location_name, 
             ST_AsText(location) as location, privacy, memory_date
      FROM memory_indices
      WHERE updated_at > :sql_last_value
    """
  }
}

output {
  elasticsearch {
    hosts => ["es-cluster:9200"]
    index => "memories"
    document_id => "%{[id]}"
  }
}
```

### 6.2 PostgreSQL → MongoDB (双写模式)

```go
// Memory Service 伪代码
func CreateMemory(ctx context.Context, req *MemoryRequest) (*Memory, error) {
    // 1. 写入 PostgreSQL (索引)
    pgMem := &MemoryIndex{
        ID: uuid.New(),
        UserID: req.UserID,
        ContentPreview: truncate(req.Content, 500),
        // ...
    }
    if err := pgDB.Create(pgMem).Error; err != nil {
        return nil, err
    }
    
    // 2. 写入 MongoDB (完整内容)
    mongoMem := &MemoryDocument{
        ID: pgMem.ID,
        UserID: req.UserID,
        Content: req.Content,
        MediaURLs: req.MediaURLs,
        // ...
    }
    if _, err := mongoDB.Collection("memories").InsertOne(ctx, mongoMem); err != nil {
        // 补偿：回滚 PostgreSQL
        pgDB.Delete(pgMem)
        return nil, err
    }
    
    // 3. 异步更新 Elasticsearch
    eventBus.Publish("memory.created", pgMem)
    
    return convertToMemory(pgMem), nil
}
```

### 6.3 区块链数据同步

```go
// NFT Service 后台监听 goroutine
func (s *NFTService) StartBlockchainListener() {
    // 连接 BSC 节点
    client, _ := ethclient.Dial("wss://bsc-ws-node.nariox.org:443")
    
    // 订阅 Transfer 事件
    query := ethereum.FilterQuery{
        Addresses: []common.Address{s.contractAddress},
        Topics: [][]common.Hash{{
            crypto.Keccak256Hash([]byte("Transfer(address,address,uint256)")),
        }},
    }
    
    logs := make(chan types.Log)
    sub, _ := client.SubscribeFilterLogs(context.Background(), query, logs)
    
    for {
        select {
        case vLog := <-logs:
            // 解析事件
            event, _ := s.contract.ParseTransfer(vLog)
            
            // 更新 PostgreSQL
            s.updateNFTOwner(event.TokenId, event.To)
            s.recordTransferHistory(event)
            
        case err := <-sub.Err():
            log.Printf("Subscription error: %v", err)
            // 重连逻辑...
        }
    }
}
```

---

## 7. 数据库备份与恢复

### 7.1 PostgreSQL 备份策略

```bash
#!/bin/bash
# 每日全量备份
pg_dump -h pg-cluster -U agarvibe_app agarvibe_main \
  | gzip > /backup/pg/agarvibe_$(date +%Y%m%d).sql.gz

# 保留最近 30 天
find /backup/pg -name "*.sql.gz" -mtime +30 -delete

# WAL 归档 (实现 PITR)
# postgresql.conf:
# wal_level = replica
# archive_mode = on
# archive_command = 'cp %p /backup/wal/%f'
```

### 7.2 MongoDB 备份策略

```bash
# 使用 mongodump
mongodump --uri="mongodb://mongo-cluster/agarvibe_docs" \
  --gzip --archive=/backup/mongo/agarvibe_$(date +%Y%m%d).gz

# 或使用文件系统快照 (推荐用于大数据量)
# 1. 锁定数据库
# 2. 创建 LVM 快照
# 3. 解锁数据库
```

### 7.3 Redis 持久化

```conf
# redis.conf
# RDB 快照
save 900 1
save 300 10
save 60 10000
dbfilename dump.rdb
dir /data

# AOF 日志
appendonly yes
appendfsync everysec
```

---

## 8. 性能优化建议

### 8.1 PostgreSQL 优化

```sql
-- 连接池配置 (PgBouncer)
[pgbouncer]
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 50

-- 慢查询日志
ALTER SYSTEM SET log_min_duration_statement = 1000;  -- 记录>1s 的查询

-- 自动 VACUUM 调优
ALTER SYSTEM SET autovacuum_vacuum_threshold = 50;
ALTER SYSTEM SET autovacuum_analyze_threshold = 50;
```

### 8.2 MongoDB 优化

```javascript
// 启用 WiredTiger 缓存 (默认 50% 物理内存)
storage:
  wiredTiger:
    engineConfig:
      cacheSizeGB: 4

// 查询优化
db.memories.find({ user_id: userId })
  .sort({ memory_date: -1 })
  .hint({ user_id: 1, memory_date: -1 });  // 强制使用索引
```

### 8.3 Redis 优化

```conf
# 内存淘汰策略
maxmemory 4gb
maxmemory-policy allkeys-lru

# 大 Key 监控
redis-cli --bigkeys

# 热 Key 监控
redis-cli --hotkeys
```

---

## 9. 数据字典下载

完整的 SQL DDL 脚本位于：
- `../scripts/schema_postgresql.sql` - PostgreSQL 完整建表脚本
- `../scripts/schema_mongodb.js` - MongoDB 索引创建脚本
- `../scripts/schema_redis.txt` - Redis 数据结构示例

---

**文档维护**: 本 Schema 设计应随业务迭代持续演进，每次变更需经过 DBA 评审并更新版本号。
