# Telegram Çoklu Grup Paylaşım Botu

Telegram yöneticilerinin onaylı çoklu grup paylaşımı yapmasını ve bayi raporlarını yönetmesini sağlar.

## Run & Operate

- `pnpm --filter @workspace/api-server run dev` — run the API server (port 5000)
- `python bots/telegram-bot/main.py` — run the Telegram bot
- `pnpm run typecheck` — full typecheck across all packages
- `pnpm run build` — typecheck + build all packages
- `pnpm --filter @workspace/api-spec run codegen` — regenerate API hooks and Zod schemas from the OpenAPI spec
- `pnpm --filter @workspace/db run push` — push DB schema changes (dev only)
- API env: `DATABASE_URL` — Postgres connection string
- Bot env: `TELEGRAM_BOT_TOKEN` (Replit Secret), `TELEGRAM_OWNER_ID` (numeric Telegram user ID)
- Bot SQLite state is stored at `bots/telegram-bot/telegram_bot.sqlite3` and excluded from Git/deployment bundles.

## Stack

- pnpm workspaces, Node.js 24, TypeScript 5.9
- API: Express 5
- DB: PostgreSQL + Drizzle ORM
- Validation: Zod (`zod/v4`), `drizzle-zod`
- API codegen: Orval (from OpenAPI spec)
- Build: esbuild (CJS bundle)

## Where things live

- `bots/telegram-bot/main.py` — Telegram bot commands, sharing, reports, and SQLite schema
- `bots/telegram-bot/README.md` — operator setup instructions
- `lib/api-spec/openapi.yaml` — shared API contract

## Architecture decisions

- The bot uses Telegram long polling and does not need an inbound webhook.
- The bot stores only message IDs and operational metadata; it does not write message media to disk.
- Only the configured owner can change admins, target groups, or the dealer recipient.

## Product

- Authorized users can draft content in Telegram DM, select groups, confirm delivery, and receive reports with real Telegram message links.
- The owner can manage admins, target groups, the dealer recipient, and retention/report settings.

## User preferences

_Populate as you build — explicit user instructions worth remembering across sessions._

## Gotchas

_Populate as you build — sharp edges, "always run X before Y" rules._

## Pointers

- See the `pnpm-workspace` skill for workspace structure, TypeScript setup, and package details
