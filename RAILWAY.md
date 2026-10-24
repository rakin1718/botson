# Railway dağıtımı

Bu depo Railway'de **tek uygulama servisi ve bir PostgreSQL servisi** olarak
çalışacak şekilde hazırlanmıştır. Uygulama servisi API panelini, ana botu ve
gönderim botunu aynı anda başlatır. Bunları ayrı uygulama servislerine
ayırmayın: panel ile bot arasındaki yerel köprü aynı servis içinde çalışır.

Railway'in proje kökünü depo kökü (`/`) olarak kullanın.

## Railway ayarları

1. Depoyu Railway projesine bağlayıp uygulama servisi oluşturun.
2. Projeye bir PostgreSQL servisi ekleyin.
3. Uygulama servisinin Variables bölümünde `DATABASE_URL` için PostgreSQL
   servisindeki `DATABASE_URL` değerine referans verin.
4. Uygulama servisinde şu komutları tanımlayın:
   - Build: `pnpm run build:railway`
   - Start: `pnpm run start:railway`
   - Healthcheck path: `/api/healthz`
5. Uygulama servisi için Railway domain'i oluşturun.

Railpack, kökteki `.node-version`, `.python-version`, `package.json`,
`pyproject.toml` ve kilit dosyalarını kullanarak Node.js, Python, pnpm ve uv
ortamlarını kurar. Railway'in verdiği `PORT` değeri API tarafından kullanılır.

## Railway Variables

Bu değerleri Railway'in Variables ekranına ekleyin; kaynak koda veya Git'e
yazmayın:

- `TELEGRAM_BOT_TOKEN`
- `TELEGRAM_SENDER_BOT_TOKEN`
- `TELEGRAM_OWNER_ID`
- `SESSION_SECRET` — en az 32 karakter
- `DATABASE_URL` — PostgreSQL servisinden referans
- `TELEGRAM_PANEL_URL` — oluşturulan domain'in `https://.../api/panel/` adresi

`PANEL_BRIDGE_PORT` ayarlanmazsa `8765` kullanılır. `PORT` değerini elle
belirlemeyin; Railway uygulama servisine kendisi verir.

## İlk veritabanı kurulumu

Botun PostgreSQL tabloları paylaşılan Drizzle şemasında tanımlıdır. İlk
yayından önce uygulama servisinin **Pre-deploy command** alanına geçici olarak
şunu yazın:

```sh
pnpm --filter @workspace/db run push
```

Bu komut Railway PostgreSQL'inde gerekli tabloları oluşturur. İlk dağıtım
başarıyla tamamlandıktan sonra pre-deploy komutunu kaldırın. Daha sonraki
şema değişikliklerini üretimde uygulamadan önce ayrıca gözden geçirip aynı
komutu kontrollü şekilde çalıştırın; şema eşitleme mevcut verileri
etkileyebilir.

## Mevcut kayıtlar

Railway PostgreSQL'i yeni ve boş bir veritabanıdır. Bu kurulum, Replit
PostgreSQL'ini veya yerel SQLite dosyalarını Railway'e kopyalamaz. Eski
kayıtları taşımak için ayrı bir dışa aktarma/aktarma adımı gerekir; aktarım
yapılmadan mevcut kayıtlar Railway'de görünmez.

## Başlatma davranışı

Uygulama başlatıcısı gerekli değişkenleri kontrol eder; eksik değer varsa
hangi değişkenin gerektiğini belirterek kapanır. Panel ve iki Telegram botu
aynı servis içinde çalıştığından Railway uygulama servisini tek replika
olarak tutun. Aynı bot token'larıyla başka bir polling süreci aynı anda
çalıştırmayın.
