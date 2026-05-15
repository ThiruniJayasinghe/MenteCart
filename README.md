# MenteCart — Service Booking with Cart

A full-stack service booking app built with Flutter (BLoC) + Node.js (Express) + MongoDB + Redis.

## Tech stack
- Flutter 3.x with BLoC pattern
- Node.js + Express + TypeScript
- MongoDB (Mongoose) with atomic transactions
- Redis (cart expiry)
- PayHere sandbox payment integration
- Docker + docker-compose
- Structured logging with Pino

## Prerequisites
- Flutter SDK (latest stable)
- Node.js 20+
- Docker + Docker Compose (for containerised run)
- OR: MongoDB 7 + Redis 7 running locally

## Environment variables

Copy `backend/.env.example` to `backend/.env` and fill in values.
Sensitive values are shared via one-time secret link.

| Variable | Description |
|---|---|
| `JWT_SECRET` | Secret for signing JWTs (min 64 chars) |
| `PAYHERE_MERCHANT_ID` | PayHere sandbox merchant ID |
| `PAYHERE_MERCHANT_SECRET` | PayHere sandbox merchant secret |
| `MONGO_URI` | MongoDB connection string |
| `REDIS_URL` | Redis connection string |

## Running with Docker

```bash
cd backend
docker-compose up -d
docker-compose exec backend npm run seed  # seed sample services
```

## Running locally

```bash
cd backend && npm install && npm run seed && npm run dev
cd mobile && flutter run 
```

## PayHere test card
- Card: 4916217501611292
- Expiry: 12/25  CVV: 100

## Architecture decisions

**Atomic overbooking prevention**: Uses MongoDB's `findOneAndUpdate` with a filter ensuring `booked < capacity`, so concurrent requests cannot overbook a slot. A 409 is returned if the slot fills up during checkout.

**Cart expiry**: Each cart item has a TTL stored in MongoDB. Expired items are removed on next cart fetch or checkout. Redis is available for future session caching.

**Status transitions**: Hard-coded valid transition map prevents illegal state changes (e.g. cancelled → pending).

**PayHere webhook idempotency**: A `PaymentLog` collection stores processed order IDs. Duplicate webhooks are silently ignored.

## Known limitations
- PayHere webhook needs a public URL (use ngrok in dev: `ngrok http 3000`)
- No push notifications for booking status changes
- No admin panel for service management
