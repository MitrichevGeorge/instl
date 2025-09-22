#!/bin/sh
# make_hello.sh - создаёт команду "hello" в ~/bin без root

set -eu

BIN="$HOME/bin"
HELLO="$BIN/hello"

echo "hello"
printf "Создаём каталог %s (если нужно)...\n" "$BIN"
mkdir -p "$BIN"


printf "Записываю %s...\n" "$HELLO"
cat > "$HELLO" <<'EOF'
#!/bin/sh
# Команда hello — выводит hello world!
printf 'hello world!\n'
EOF

chmod +x "$HELLO"
printf "Готово: %s создан и отмечен как исполняемый.\n" "$HELLO"

# Проверим, есть ли ~/bin в PATH
case ":$PATH:" in
  *":$BIN:"*)
    printf "Каталог %s уже в PATH — можете сразу запускать команду: hello\n" "$BIN"
    ;;
  *)
    # Добавим экспорт в ~/.bashrc, если там ещё нет
    if [ -w "$HOME/.bashrc" ] || [ ! -e "$HOME/.bashrc" ]; then
      if ! grep -Fqx 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
        printf "\n# добавить ~/bin в PATH, создано скриптом make_hello.sh\nexport PATH=\"$HOME/bin:\$PATH\"\n" >> "$HOME/.bashrc"
        printf "Добавил строку в %s для постоянного добавления ~/bin в PATH.\n" "$HOME/.bashrc"
      else
        printf "%s уже содержит добавление ~/bin в PATH.\n" "$HOME/.bashrc"
      fi
    else
      printf "Не удалось записать в %s — добавьте вручную: export PATH=\\\"$HOME/bin:\\$PATH\\\"\n" "$HOME/.bashrc"
    fi

    # Попробуем также добавить в ~/.profile (для логин-шеллов), если возможно
    if [ -w "$HOME/.profile" ] || [ ! -e "$HOME/.profile" ]; then
      if ! grep -Fqx 'export PATH="$HOME/bin:$PATH"' "$HOME/.profile" 2>/dev/null; then
        printf "\n# добавить ~/bin в PATH, создано скриптом make_hello.sh\nexport PATH=\"$HOME/bin:\$PATH\"\n" >> "$HOME/.profile"
        printf "Добавил строку в %s.\n" "$HOME/.profile"
      fi
    fi

    printf "Чтобы начать использовать команду прямо сейчас, выполните в текущем терминале:\n\n  source ~/.bashrc\n\nили откройте новый терминал. После этого команда доступна как: hello\n"
    ;;
esac

printf "Удачи!\n"

ls
