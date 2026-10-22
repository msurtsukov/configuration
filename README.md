# configuration

Настройки терминала для macOS: [Ghostty](https://ghostty.org) + [herdr](https://herdr.dev).

```sh
git clone https://github.com/msurtsukov/configuration.git
cd configuration
./install.sh
```

Скрипт:

1. ставит Homebrew (если нет), Ghostty (`brew install --cask ghostty`) и herdr (`herdr.dev/install.sh` → `~/.local/bin`);
2. копирует SF Mono из Terminal.app в `~/Library/Fonts`;
3. раскладывает конфиги (прежние, если отличаются, сохраняет в `*.bak-<дата>`);
4. ставит интеграцию herdr для Claude Code (если `claude` установлен);
5. назначает Ghostty программой по умолчанию для `.command`/`.sh`/исполняемых файлов.

## Что где

| Файл в репо | Куда |
|---|---|
| `ghostty/config.ghostty` | `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` |
| `ghostty/themes/iterm2-classic` | `~/.config/ghostty/themes/iterm2-classic` |
| `herdr/config.toml` | `~/.config/herdr/config.toml` |
| `macos/set-default-terminal.swift` | запускается из `install.sh` |

## Особенности

- **Цвета** — палитра профиля Default из iTerm2, слегка смягчённая (зелёный текст на почти чёрном фоне).
- **Шрифт** — SF Mono 13, без `font-thicken`.
- **Клавиши** — Ghostty не перехватывает `cmd+t/w/d`, `cmd+shift+d`, `cmd+1..9`, `cmd+[ ]`, `cmd+shift+[ ]`: их обрабатывает herdr. Вкладки Ghostty — `cmd+shift+t/w`, `ctrl+tab`.
- **Русская раскладка** — команды Ghostty привязаны к физическим клавишам (`key_c` и т.п.); сочетания herdr Ghostty отправляет как латинские kitty-последовательности; в herdr после `ctrl+b` раскладка временно переключается на латиницу (`switch_ascii_input_source_in_prefix`).
