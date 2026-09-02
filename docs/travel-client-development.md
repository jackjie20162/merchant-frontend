# Travel merchant client development

## Role

`merchant-frontend` is the supplier/merchant console for publishing tourism products and managing the tourism lifecycle: product, package/SKU, dates, time slots, pricing, inventory, orders, travelers, vouchers, redemption, cancellation and refunds.

## Runtime boundary

`merchant-frontend -> HTTPS REST -> travel-api -> gRPC -> travel-rpc -> Ent/MySQL`.

The merchant frontend must not call `travel-rpc`, MySQL, or add `merchant-api2/merchant-rpc` as a runtime dependency for Travel.

## Current test baseline

The repository already contains a Tauri 2 shell and Travel API client. Tourism navigation includes dashboard, products, inventory, orders and payment. The Tauri shell should be used as the desktop distribution target while the web UI remains available for development.

Before release, verify: product CRUD against Travel API, inventory operations, order creation consistency, PayPal Sandbox checkout/webhook, voucher redemption, cancellation/refund, permissions and production HTTPS.
