# Travel 商户端插件

目录：`src/plugin/travel/`

运行边界严格保持：

```text
merchant-frontend / plugin/travel
        │ REST/HTTP
        ▼
   travel-api
        │ gRPC
        ▼
   travel-rpc
        │
        ▼
      Ent/MySQL
```

Travel 插件不调用 `merchant-api2`、`merchant-rpc`，也不直接访问 Travel 数据库。

## 页面

- `/plugin/travel/dashboard/index`：旅游商户工作台
- `/plugin/travel/products/index`：旅游产品目录、详情
- `/plugin/travel/inventory/index`：日期/时段库存检查
- `/plugin/travel/orders/index`：旅游订单查询；待支付订单可进入支付页
- `/plugin/travel/payment/index`：创建 Travel Payment、查看支付状态、轮询支付状态

## API

`api.js` 仅作为 `src/api/travel.js` 的商户插件门面，实际 REST 请求仍由 `travel-api` 完成。

支付接口：

- `POST /api/travel/payments`：按订单创建支付单，要求 `orderNo/provider/idempotencyKey`
- `GET /api/travel/payments/:paymentNo`：查询支付状态

## 支付事实来源

商户端不修改支付状态，也不伪造支付成功。Payment 状态来自 `travel-api -> travel-rpc -> Payment`；后续接入 PayPal 等真实支付渠道时，由服务端 provider/webhook 驱动 `PAID`，前端仅展示和轮询状态。

## 当前状态

订单 → 创建支付单 → 支付状态查询/轮询已经接通 Travel 独立服务链路。当前仓库已存在 PayPal 配置项，但本次没有虚构 PayPal checkout URL 或 webhook 成功；真实第三方支付创建与 webhook 签名校验仍需作为下一阶段 provider 实现。
