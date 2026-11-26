[ENG](#eng)

# bash-aliases

Алиасы для `~/.bashrc` и скрипт для их обновления.

## Файлы

- `custom-aliases.sh` - кастомный блок с алиасами.
- `update-aliases.sh` - скачивает блок и заменяет его в `~/.bashrc`.

## Добавление алиасов из custom-aliases.sh в ~/.bashrc

```bash
bash -c "$(curl -SsfL https://raw.githubusercontent.com/aiovin/bash-aliases/refs/heads/main/update-aliases.sh)" && source ~/.bashrc
```

С указанием города для алиаса погоды (по умолчанию `Abakan`):

```bash
bash -c "$(curl -SsfL https://raw.githubusercontent.com/aiovin/bash-aliases/refs/heads/main/update-aliases.sh)" -- --weather-city Alaska && source ~/.bashrc
```

В алиасы входит команда `update-aliases` для их последующего обновления (опционально с городом для алиасов погоды):

```bash
update-aliases --weather-city Alaska
```

Опции:

- `-w, --weather-city CITY` - город для прогноза погоды (только латиница, `_` и `-`)
- `-h, --help` - справка

## Crontab пример

```bash
0 0 * * * { f=$(mktemp) && curl -SsfL https://raw.githubusercontent.com/aiovin/bash-aliases/refs/heads/main/update-aliases.sh -o "$f" && bash "$f" --weather-city Alaska; rm -f "$f"; } >> $HOME/var/log/bash-aliases.log 2>&1
```

## Что именно делает скрипт

1. Проверяет, что в текущем `~/.bashrc` либо оба маркера, либо ни одного (одинокий маркер останавливает скрипт).
2. Скачивает `custom-aliases.sh` и проверяет, что файл не битый (не пустой, правильные первая и последняя строки с маркерами).
3. Делает бэкап `~/.bashrc` в `~/.bashrc.bak` (перезаписывается при каждом запуске).
4. Удаляет старый блок, дописывает новый, схлопывает повторяющиеся пустые строки.
5. Если передан `--weather-city`, заменяет `Abakan` на указанный город.

## Заметки

- Всё между маркерами перезаписывается при каждом обновлении. Свои правки держи вне блока.
- Город сбрасывается на `Abakan` при следующем запуске без `--weather-city`.
- Нужны: Debian/Ubuntu с systemd, `curl` и GNU `sed`.

## ENG

# bash-aliases

Aliases for `~/.bashrc` and a script to update them.

## Files

- `custom-aliases.sh` - a custom block containing aliases.
- `update-aliases.sh` - downloads the block and replaces it in `~/.bashrc`.

## Add the aliases from custom-aliases.sh to ~/.bashrc

```bash
bash -c "$(curl -SsfL https://raw.githubusercontent.com/aiovin/bash-aliases/refs/heads/main/update-aliases.sh)" && source ~/.bashrc
```

To specify a city for the weather alias (defaults to `Abakan`):

```bash
bash -c "$(curl -SsfL https://raw.githubusercontent.com/aiovin/bash-aliases/refs/heads/main/update-aliases.sh)" -- --weather-city Alaska && source ~/.bashrc
```

The aliases include a built-in `update-aliases` command for updating them later (optionally with a city for the weather aliases):

```bash
update-aliases --weather-city Alaska
```

Options:

- `-w, --weather-city CITY` - city for the weather forecast (Latin letters, `_` and `-` only).
- `-h, --help` - display help.

## Crontab example

```bash
0 0 * * * { f=$(mktemp) && curl -SsfL https://raw.githubusercontent.com/aiovin/bash-aliases/refs/heads/main/update-aliases.sh -o "$f" && bash "$f" --weather-city Alaska; rm -f "$f"; } >> $HOME/var/log/bash-aliases.log 2>&1
```

## What the Script Does

1. Checks that either both markers or neither marker are present in the current `~/.bashrc` (a single marker causes the script to abort).
2. Downloads `custom-aliases.sh` and verifies that the file is valid (not empty, with the correct first and last marker lines).
3. Creates a backup of `~/.bashrc` at `~/.bashrc.bak` (overwritten on each run).
4. Removes the old block, appends the new one, and collapses consecutive empty lines.
5. If `--weather-city` is specified, replaces `Abakan` with the provided city.

## Notes

- Everything between the markers is overwritten on each update. Keep your custom modifications outside this block.
- The city is reset to `Abakan` on the next run without `--weather-city`.
- Requirements: Debian/Ubuntu with systemd, `curl`, and GNU `sed`.
