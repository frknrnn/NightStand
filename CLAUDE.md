# NightStand

Qt/QML nightstand clock uygulaması. Kaynak kod `NightStand/` altında, CMake ile derleniyor.

## Git workflow

- **Tüm iş `development` branch'inde yapılır.** `main`'e asla doğrudan commit atma.
- Bu repo'da sadece iki branch bulunur: `main` (stabil) ve `development` (aktif iş).
  Kullanıcı açıkça istemedikçe feature/topic/worktree branch'i açma.
- `main` veya başka bir branch üzerindeysen, değişiklik yapmadan önce
  `git checkout development` ile geç.
- `main` yalnızca kullanıcı istediğinde, `development` merge edilerek güncellenir.
- Aynı repo'da paralel Claude oturumları çalışıyor olabilir: commit öncesi `git status`
  ile ağacı doğrula ve `git commit <path> -m "..."` şeklinde pathspec vererek commit at,
  böylece başka bir oturumun değişikliklerini yanlışlıkla almazsın.

## Build

Derlemeyi kullanıcı kendisi yapıyor — `cmake`, `make` veya başka bir build komutu çalıştırma.
