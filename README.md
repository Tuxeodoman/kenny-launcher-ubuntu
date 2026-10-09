# Kenny Launcher для Ubuntu

Готовый пакет **9.6.1-dev** для **Ubuntu 24.04 x86_64** и систем на её базе. Qt и Java 8/17/21/25 включены. Нужно около 3 ГБ свободного места без учёта Minecraft.

Установка из терминала обычного пользователя:

```bash
curl -fLO https://github.com/Tuxeodoman/kenny-launcher-ubuntu/releases/download/v9.6.1-dev-ubuntu-r1/install.sh
bash install.sh
```

Откройте **Kenny Launcher Dev** в меню приложений или выполните:

```bash
~/.local/bin/kenny-launcher-ubuntu
```

Войдите в свой аккаунт и скачайте сборку. Установщик запросит пароль для установки системных библиотек; сам лаунчер запускайте без sudo.

Для NixOS: https://github.com/Tuxeodoman/kenny-launcher-nixos

Обновление: закройте лаунчер и снова выполните установщик из нового релиза этого репозитория. Сборки и аккаунт сохраняются.

Проверено в Ubuntu 24.04: вход через VK, Vanilla 1.21.10, защищённая Avaloria и её карта. В VMware для Avaloria отключите «Постоянный буфер памяти» в расширенных настройках Sodium, если не видны блоки.
