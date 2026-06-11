# Konekta Backend

Express.js + TypeScript + MySQL REST API.

## Setup

```bash
# 1. install deps
npm install

# 2. set up env
cp .env.example .env
# edit DB credentials and JWT_SECRET

# 3. import the schema (run from the project root)
mysql -u root -p < ../database/schema.sql

# 4. run in dev mode
npm run dev
# or build + start
npm run build && npm start
```

The server starts on `http://localhost:4000` by default.

## Project structure

```
src/
  config/        # env, mysql pool
  controllers/   # express route handlers
  middlewares/   # auth (JWT), error handling
  routes/        # express routers
  services/      # business logic & data access
  utils/         # helpers
  app.ts         # express app
  server.ts      # entrypoint
```

## Endpoints

| Method | Path                              | Auth | Description                          |
|--------|-----------------------------------|------|--------------------------------------|
| POST   | /auth/register                    | -    | Create account                       |
| POST   | /auth/login                       | -    | Log in                               |
| POST   | /auth/logout                      | -    | Drop session                         |
| POST   | /auth/forgot-password             | -    | Request password reset               |
| GET    | /profile/me                       | JWT  | Get own profile                      |
| PUT    | /profile/me                       | JWT  | Update own profile                   |
| PUT    | /profile/brand                    | JWT  | Update brand profile                 |
| POST   | /profile/influencer/social-media  | JWT  | Add social account                   |
| GET    | /influencers                      | -    | List / search influencers            |
| GET    | /influencers/:id                  | -    | Influencer detail                    |
| GET    | /brands                           | -    | List / search brands                 |
| GET    | /brands/:id                       | -    | Brand detail                         |
| POST   | /offers                           | JWT  | Create offer (brand only)            |
| GET    | /offers                           | JWT  | List my offers                       |
| GET    | /offers/:id                       | -    | Offer detail                         |
| PATCH  | /offers/:id/status                | JWT  | Update status                        |
| GET    | /conversations                    | JWT  | List conversations                   |
| POST   | /conversations                    | JWT  | Start conversation                   |
| GET    | /conversations/:id/messages       | JWT  | List messages                        |
| POST   | /conversations/:id/messages       | JWT  | Send message                         |
| GET    | /notifications                    | JWT  | List notifications                   |
| PATCH  | /notifications/:id/read           | JWT  | Mark as read                         |
| PATCH  | /notifications/read-all           | JWT  | Mark all as read                     |
| GET    | /dashboard/overview               | JWT  | Dashboard summary                    |
```
