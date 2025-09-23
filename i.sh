#!/bin/sh
# make_hello.sh - создаёт команды "hello" и "p" в ~/bin без root

set -eu

BIN="$HOME/bin"
HELLO="$BIN/hello"
P_GUI="$BIN/p"

echo "hello"
printf "Создаём каталог %s (если нужно)...\n" "$BIN"
mkdir -p "$BIN"

# --- hello ---
printf "Записываю %s...\n" "$HELLO"
cat > "$HELLO" <<'EOF'
#!/bin/sh
# Команда hello — выводит hello world!
printf 'hello world!\n'
EOF
chmod +x "$HELLO"

# --- p (Python GUI) ---
printf "Создаю Python GUI-программу %s...\n" "$P_GUI"
cat > "$P_GUI" <<'EOF'
#!/bin/sh
# Команда p — показывает уведомление через Python (notify2)

VENV="$HOME/bin/p-venv"

# создать venv, если нет
if [ ! -d "$VENV" ]; then
  printf "Создаю виртуальное окружение в %s...\n" "$VENV"
  python3 -m venv "$VENV" || exit 1
  "$VENV/bin/pip" install --quiet --upgrade pip setuptools wheel
  "$VENV/bin/pip" install --quiet notify2
fi

# запуск Python-кода
"$VENV/bin/python" - <<'PY'
import notify2, sys

try:
    notify2.init("Приветствие")
    n = notify2.Notification("Привет!", "Это уведомление от команды p")
    n.show()
except Exception as e:
    print("Ошибка показа уведомления:", e, file=sys.stderr)
    print("Привет (fallback в консоль)")
PY
EOF
chmod +x "$P_GUI"

# --- PATH ---
case ":$PATH:" in
  *":$BIN:"*)
    printf "Каталог %s уже в PATH — можете запускать команды: hello, p\n" "$BIN"
    ;;
  *)
    # bashrc
    if [ -w "$HOME/.bashrc" ] || [ ! -e "$HOME/.bashrc" ]; then
      if ! grep -Fqx 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
        printf "\n# добавить ~/bin в PATH, создано скриптом make_hello.sh\nexport PATH=\"$HOME/bin:\$PATH\"\n" >> "$HOME/.bashrc"
        printf "Добавил строку в %s для постоянного добавления ~/bin в PATH.\n" "$HOME/.bashrc"
      fi
    fi
    # profile
    if [ -w "$HOME/.profile" ] || [ ! -e "$HOME/.profile" ]; then
      if ! grep -Fqx 'export PATH="$HOME/bin:$PATH"' "$HOME/.profile" 2>/dev/null; then
        printf "\n# добавить ~/bin в PATH, создано скриптом make_hello.sh\nexport PATH=\"$HOME/bin:\$PATH\"\n" >> "$HOME/.profile"
        printf "Добавил строку в %s.\n" "$HOME/.profile"
      fi
    fi
    printf "Чтобы использовать команды прямо сейчас:\n\n  source ~/.bashrc\n\nили откройте новый терминал.\n"
    ;;
esac

# --- автозапуск GUI ---
AUTOSTART="$HOME/.config/autostart"
mkdir -p "$AUTOSTART"
cat > "$AUTOSTART/p.desktop" <<EOF
[Desktop Entry]
Type=Application
Exec=$P_GUI
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Приветствие
Comment=Показывает приветствие при старте
EOF

printf "Добавил GUI-программу в автозапуск: %s/p.desktop\n" "$AUTOSTART"

# --- закрыть текущий терминал ---
printf "Закрываем текущий терминал...\n"
kill -9 $$
