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
- `/plugin/travel/orders/index`：旅游订单查询

## API

`api.js` 仅作为 `src/api/travel.js` 的商户插件门面，实际 REST 请求仍由 `travel-api` 完成。

## 当前状态

已实现前端页面与路由接入；支付页面暂不伪造支付成功。后续支付页面应接入 Travel 自身 Payment API，并由 webhook/服务端状态作为最终支付事实来源。
