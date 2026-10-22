#!/usr/bin/env bash
# Устанавливает Ghostty + herdr и раскладывает конфиги из этого репозитория.
# Повторный запуск безопасен: уже установленное пропускается, а существующие
# конфиги, которые отличаются от репозиторных, сохраняются в *.bak-<дата>.
#
#   git clone https://github.com/msurtsukov/configuration.git && cd configuration && ./install.sh
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

GHOSTTY_APP="/Applications/Ghostty.app"
GHOSTTY_BIN="$GHOSTTY_APP/Contents/MacOS/ghostty"
GHOSTTY_CONFIG_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
GHOSTTY_THEMES_DIR="$HOME/.config/ghostty/themes"
HERDR_CONFIG_DIR="$HOME/.config/herdr"
SF_MONO_SRC="/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts"

step() { printf '\n\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

# Копирует файл, сохраняя прежнюю версию, если она отличается.
install_file() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -f "$dst" ]] && ! cmp -s "$src" "$dst"; then
    cp "$dst" "$dst.bak-$STAMP"
    echo "  backup: $dst.bak-$STAMP"
  fi
  cp "$src" "$dst"
  echo "  $dst"
}

[[ "$(uname -s)" == "Darwin" ]] || { echo "Скрипт рассчитан на macOS" >&2; exit 1; }

step "Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$b" ]] && eval "$("$b" shellenv)" && break
  done
fi
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
fi
echo "  $(brew --version | head -1)"

step "Ghostty"
if [[ -d "$GHOSTTY_APP" ]]; then
  echo "  уже установлен: $("$GHOSTTY_BIN" +version 2>/dev/null | head -1)"
else
  brew install --cask ghostty
fi

step "herdr"
export PATH="$HOME/.local/bin:$PATH"
if command -v herdr >/dev/null 2>&1; then
  echo "  уже установлен: $(herdr --version)"
else
  curl -fsSL https://herdr.dev/install.sh | sh
fi
command -v herdr >/dev/null 2>&1 || { echo "herdr не найден в PATH после установки" >&2; exit 1; }
case ":$(zsh -ic 'echo $PATH' 2>/dev/null):" in
  *":$HOME/.local/bin:"*) ;;
  *) warn "~/.local/bin нет в PATH вашего shell — добавьте в ~/.zshrc: export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
esac

step "Шрифт SF Mono (из Terminal.app в ~/Library/Fonts)"
if [[ -d "$SF_MONO_SRC" ]]; then
  mkdir -p "$HOME/Library/Fonts"
  cp -n "$SF_MONO_SRC"/SF-Mono-*.otf "$HOME/Library/Fonts/" 2>/dev/null || true
  echo "  $(ls "$HOME/Library/Fonts" | grep -c '^SF-Mono-') файлов SF Mono"
else
  warn "SF Mono не найден в $SF_MONO_SRC — Ghostty откатится на встроенный шрифт"
fi

step "Конфиги Ghostty"
install_file "$REPO/ghostty/config.ghostty" "$GHOSTTY_CONFIG_DIR/config.ghostty"
install_file "$REPO/ghostty/themes/iterm2-classic" "$GHOSTTY_THEMES_DIR/iterm2-classic"
for extra in "$HOME/.config/ghostty/config" "$HOME/.config/ghostty/config.ghostty"; do
  [[ -f "$extra" ]] && warn "Ghostty также читает $extra — его настройки смешаются с репозиторными"
done
"$GHOSTTY_BIN" +validate-config && echo "  ghostty: config ok"

step "Конфиг herdr"
install_file "$REPO/herdr/config.toml" "$HERDR_CONFIG_DIR/config.toml"
herdr config check
herdr server reload-config >/dev/null 2>&1 && echo "  запущенный herdr перечитал конфиг" || true
if command -v claude >/dev/null 2>&1; then
  herdr integration install claude
else
  echo "  claude не найден — интеграцию поставьте позже: herdr integration install claude"
fi

step "Ghostty — терминал по умолчанию для скриптов"
if command -v swift >/dev/null 2>&1; then
  swift "$REPO/macos/set-default-terminal.swift" 2>/dev/null || warn "не удалось назначить обработчик"
else
  warn "swift не найден (xcode-select --install), пропускаю"
fi

step "Готово"
echo "  Запустите Ghostty (или перезагрузите конфиг: cmd+shift+,) и наберите herdr."
