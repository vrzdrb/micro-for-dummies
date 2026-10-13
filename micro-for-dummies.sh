#!/usr/bin/env bash
#===============================================================================
#  micro-setup.sh — интерактивная установка и настройка текстового редактора micro
#===============================================================================

set -u

YELLOW='\033[38;2;230;255;0m'
GREEN='\033[32m'
RED='\033[31m'
RESET='\033[0m'

MSG=""

SETTINGS="$HOME/.config/micro/settings.json"
BACKUP_DIR="$HOME/.config/micro/backup"
# ranger/vifm/mc читают конфиги из $XDG_CONFIG_HOME, если он задан
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

#------------------------------------------------------------------------------#
#  Шапка                                                                        #
#------------------------------------------------------------------------------#
print_header() {
    clear
    echo -e "${YELLOW}"
    cat <<'EOF'
            _                                 
           (_)                                
  _ __ ___  _  ___ _ __ ___                   
 | '_ ` _ \| |/ __| '__/ _ \                  
 | | | | | | | (__| | | (_) |                 
 |_|_|_| |_|_|\___|_|  \___/                  
  / _|                                        
 | |_ ___  _ __                               
 |  _/ _ \| '__|                              
 | || (_) | |                                 
 |_| \___/|_|                     _           
     | |                         (_)          
   __| |_   _ _ __ ___  _ __ ___  _  ___  ___ 
  / _` | | | | '_ ` _ \| '_ ` _ \| |/ _ \/ __|
 | (_| | |_| | | | | | | | | | | | |  __/\__ \
  \__,_|\__,_|_| |_| |_|_| |_| |_|_|\___||___/
EOF
    echo -e "${RESET}"
}

#------------------------------------------------------------------------------#
#  Утилиты                                                                      #
#------------------------------------------------------------------------------#
pause() {
    echo
    read -r -p "$(echo -e "${YELLOW}${T[pause_prompt]}${RESET}")" _
    echo -ne "${YELLOW}"
}

have() { command -v "$1" >/dev/null 2>&1; }


#------------------------------------------------------------------------------#
#  Локализация (i18n)                                                           #
#------------------------------------------------------------------------------#
UI_LANG="ru"
LANG_DIR="$HOME/.config/micro-for-dummies"
[ -f "$LANG_DIR/lang" ] && UI_LANG=$(tr -d '[:space:]' < "$LANG_DIR/lang" 2>/dev/null)
case "$UI_LANG" in ru|en) ;; *) UI_LANG="ru" ;; esac

declare -A T
load_translations() {
    if [ "$UI_LANG" = "en" ]; then
        T=(
            [pause_prompt]="Press Enter to return to the menu..."
            [already_installed]="micro is already installed:"
            [not_installed]="micro is not installed."
            [ask_reset_editor]="Reset the default editor after removal? [Y/n] "
            [cur_version]="  Current version:"
            [i_del_micro]="  1) Remove micro"
            [i_install_micro]="  1) Install micro"
            [back]="  0) Back"
            [choice]="Choice: "
            [found_editors]="  Found installed editors:"
            [editor_number]="  Editor number (Enter to cancel): "
            [run_item1_first]="  micro is not installed — run item 1 first."
            [clipboard_cur]="  Current 'clipboard' value:"
            [not_set]="not set"
            [clip_enable]="  1) Enable clipboard (OSC 52)"
            [clip_disable]="  2) Disable"
            [msg_clip_on]="✔ Clipboard enabled"
            [msg_clip_off]="✔ Clipboard disabled"
            [msg_installed]="✔ micro installed:"
            [msg_install_failed]="✘ Failed to install micro"
            [msg_remove_failed]="✘ Failed: micro is still installed"
            [msg_removed_ok]="✔ micro removed. Settings backed up to"
            [msg_mc_builtin_off]="✔ mc: built-in editor disabled (F4 → external \$EDITOR)"
            [no_editors]="No editors found on the system!"
            [die_tools]="Need jq or python3 to edit $SETTINGS"
            [die_download]="Failed to download micro"
            [die_tty]="This script is interactive — run it in a terminal."
            [msg_theme]="✔ Theme:"
            [fm_ed_note]="takes the editor from \$EDITOR — set it in item 2"
            [msg_mc_builtin_off]="✔ mc: built-in editor disabled (F4 → external \$EDITOR)"
            [enter_theme_name]="   *) Enter theme name manually"
            [theme_name]="Theme name: "
            [no_term_found]="  Could not detect a terminal automatically."
            [term_cmd_prompt]="  Enter launch command (e.g. foot micro %F): "
            [found_terminals]="  Found terminals:"
            [enter_manually]="   *) Enter command manually"
            [cancel]="   0) Cancel"
            [which_term]="  Which terminal should open micro? [1]: "
            [launch_cmd]="  Launch command: "
            [msg_desktop]="✔ micro.desktop created"
            [no_fms]="  No console file managers found (ranger, mc, vifm, nnn, lf, yazi...)."
            [found_fms]="  Found file managers:"
            [which_fm]="  Which one to configure? (Enter to cancel): "
            [cur_marker]="  ← current"
            [cur_default_marker]="  ← current default"
            [no_such]="No such item"
            [ask_mc_system]="Make @EDITOR@ the system-wide default editor? [Y/n] "
            [mc_external_note]="  mc doesn't store the editor path, it uses \$EDITOR."
            [msg_mc_via]="✔ mc: F4 → @EDITOR@ (via \$EDITOR)"
            [msg_mc_external]="✔ mc: external editor (see item 2 for \$EDITOR)"
            [msg_ranger]="✔ ranger: text files →"
            [msg_vifm]="✔ vifm: vicmd →"
            [msg_fm_uses_editor]="uses \$EDITOR (item 2)"
            [no_foot]="  No “(Foot)” shortcuts found — nothing to clean up."
            [found_legacy]="  Found legacy shortcuts:"
            [ask_delete]="  Delete them? [Y/n] "
            [removed]="✔ Removed shortcuts:"
            [msg_removed]="✔ Removed (Foot) shortcuts:"
            [msg_lang]="✔ Language: English"
            [fish_updated]="✔ fish: config.fish and conf.d updated"
            [m_installed]="installed"
            [m_not_installed]="micro is not installed"
            [default_editor]="Default editor:"
            [m1]="Install / remove micro"
            [m2]="Set default editor"
            [m3]="Clipboard management (OSC 52)"
            [m4]="Autosave on focus loss ............"
            [m5]="Mouse support ....................."
            [m6]="Statusline ........................"
            [m7]="Ruler (line/column) ..............."
            [m8]="Tabs → spaces ....................."
            [m9]="Soft-wrap long lines .............."
            [m10]="Auto-sudo on save ................."
            [m11]="Keep new line indent .............."
            [m12]="Color scheme ......................"
            [m13]=".desktop entry for micro .........."
            [m14]="File managers (ranger, mc) ........"
            [m15]="Remove legacy “(Foot)” shortcuts"
            [m16]="Язык / Language"
            [m0]="Exit"
            [st_created]="created"
            [st_none]="none"
            [st_yes]="configured"
            [st_no]="not configured"
            [true_word]="true"
            [false_word]="false"
        )
    else
        T=(
            [pause_prompt]="Нажмите Enter, чтобы вернуться в меню..."
            [already_installed]="micro уже установлен:"
            [not_installed]="micro и так не установлен."
            [ask_reset_editor]="Сбросить редактор по умолчанию на другой после удаления? [Y/n] "
            [cur_version]="  Текущая версия:"
            [i_del_micro]="  1) Удалить micro"
            [i_install_micro]="  1) Установить micro"
            [back]="  0) Назад"
            [choice]="Выбор: "
            [found_editors]="  Найдены установленные редакторы:"
            [editor_number]="Номер редактора (Enter — отмена): "
            [run_item1_first]="  micro не установлен — сначала выполните пункт 1."
            [clipboard_cur]="  Текущее значение 'clipboard':"
            [not_set]="не задано"
            [clip_enable]="  1) Включить буфер обмена (OSC 52)"
            [clip_disable]="  2) Отключить"
            [msg_clip_on]="✔ Буфер обмена включён"
            [msg_clip_off]="✔ Буфер обмена отключён"
            [msg_installed]="✔ micro установлен:"
            [msg_install_failed]="✘ Не удалось установить micro"
            [msg_remove_failed]="✘ Что-то пошло не так, micro всё ещё в системе"
            [msg_removed_ok]="✔ micro удалён. Настройки сохранены в"
            [msg_mc_builtin_off]="✔ mc: встроенный редактор отключён (F4 → редактор из \$EDITOR)"
            [no_editors]="В системе не найдено ни одного редактора!"
            [die_tools]="Нужен jq или python3 для правки $SETTINGS"
            [die_download]="Не удалось скачать micro"
            [die_tty]="Скрипт интерактивный — запустите в терминале."
            [msg_theme]="✔ Тема:"
            [fm_ed_note]="берёт редактор из переменной \$EDITOR — настройте её пунктом 2"
            [enter_theme_name]="   *) Ввести имя темы вручную"
            [theme_name]="Имя темы: "
            [no_term_found]="  Не удалось определить терминал автоматически."
            [term_cmd_prompt]="  Введите команду запуска (например: foot micro %F): "
            [found_terminals]="  Найдены терминалы:"
            [enter_manually]="   *) Ввести команду вручную"
            [cancel]="   0) Отмена"
            [which_term]="  В каком терминале открывать micro? [1]: "
            [launch_cmd]="  Команда запуска: "
            [msg_desktop]="✔ micro.desktop создан"
            [no_fms]="  Не найдено консольных файловых менеджеров (ranger, mc, vifm, nnn, lf, yazi...)."
            [found_fms]="  Найдены файловые менеджеры:"
            [which_fm]="  Для какого настроить редактор? (Enter — отмена): "
            [cur_marker]="  ← текущий"
            [cur_default_marker]="  ← текущий по умолчанию"
            [no_such]="Нет такого пункта"
            [ask_mc_system]="Назначить @EDITOR@ редактором по умолчанию системно? [Y/n] "
            [mc_external_note]="  mc не хранит путь к редактору, а берёт его из \$EDITOR."
            [msg_mc_via]="✔ mc: F4 → @EDITOR@ (через \$EDITOR)"
            [msg_mc_external]="✔ mc: внешний редактор (см. пункт 2 для \$EDITOR)"
            [msg_ranger]="✔ ranger: текстовые файлы →"
            [msg_vifm]="✔ vifm: vicmd →"
            [msg_fm_uses_editor]="использует \$EDITOR (пункт 2)"
            [no_foot]="  Ярлыков «(Foot)» не найдено — убирать нечего."
            [found_legacy]="  Найдены устаревшие ярлыки:"
            [ask_delete]="  Удалить их? [Y/n] "
            [removed]="✔ Удалено ярлыков:"
            [msg_removed]="✔ Удалено ярлыков (Foot):"
            [msg_lang]="✔ Язык: русский"
            [fish_updated]="✔ fish: config.fish и conf.d обновлены"
            [m_installed]="установлен"
            [m_not_installed]="micro не установлен"
            [default_editor]="Редактор по умолчанию:"
            [m1]="Установка / удаление micro"
            [m2]="Выбрать редактор по умолчанию"
            [m3]="Управление буфером обмена"
            [m4]="Автосохранение по фокусу .........."
            [m5]="Поддержка мыши ...................."
            [m6]="Строка статуса ...................."
            [m7]="Линейка (номера/позиция) .........."
            [m8]="Табы → пробелы ...................."
            [m9]="Перенос длинных строк ............."
            [m10]="Авто-sudo при сохранении .........."
            [m11]="Сохранять отступ новой строки ....."
            [m12]="Тема оформления ..................."
            [m13]=".desktop-файл для micro ..........."
            [m14]="Файловые менеджеры (ranger, mc) ..."
            [m15]="Убрать старые ярлыки «(Foot)»"
            [m16]="Язык / Language"
            [m0]="Выход"
            [st_created]="создан"
            [st_none]="нет"
            [st_yes]="настроено"
            [st_no]="не настроено"
            [true_word]="true"
            [false_word]="false"
        )
    fi
}
load_translations

toggle_language() {
    if [ "$UI_LANG" = "ru" ]; then UI_LANG="en"; else UI_LANG="ru"; fi
    mkdir -p "$LANG_DIR"
    echo "$UI_LANG" > "$LANG_DIR/lang"
    load_translations
    MSG="${T[msg_lang]}"
}

die() { echo -e "${RED}$*${RESET}"; exit 1; }

# Безопасно меняет/добавляет JSON-ключ в settings.json micro (jq → python3)
set_setting() {
    local key="$1" value="$2"
    mkdir -p "$(dirname "$SETTINGS")"
    touch "$SETTINGS"
    # пустой файл: jq >= 1.6 молча отдаёт rc=0 и пустой вывод — подсовываем {}
    [ -s "$SETTINGS" ] || echo '{}' > "$SETTINGS"

    if have jq; then
        jq --arg k "$key" --argjson v "$value" '. + {($k): $v}' "$SETTINGS" \
            > "$SETTINGS.tmp" 2>/dev/null \
            && mv "$SETTINGS.tmp" "$SETTINGS" && return 0
    fi

    if have python3; then
        python3 - "$SETTINGS" "$key" "$value" <<'PYEOF'
import json, sys, os
path, key, value = sys.argv[1], sys.argv[2], sys.argv[3]
data = {}
try:
    with open(path) as f:
        raw = f.read().strip()
        if raw:
            data = json.loads(raw)
except Exception:
    data = {}
try:
    data[key] = json.loads(value)
except Exception:
    data[key] = value
tmp = path + ".tmp"
with open(tmp, "w") as f:
    json.dump(data, f, indent=4, ensure_ascii=False)
os.replace(tmp, path)
PYEOF
        return 0
    fi

    die "${T[die_tools]}"
}

get_setting() {
    local key="$1"
    [ -f "$SETTINGS" ] || return 1
    if have jq; then
        jq -r ".[\"$key\"] // empty" "$SETTINGS" 2>/dev/null
    elif have python3; then
        python3 -c "import json;d=json.load(open('$SETTINGS'));print(d.get('$key',''))" 2>/dev/null
    else
        grep -o "\"$key\"[^,}]*" "$SETTINGS" 2>/dev/null | head -1 | sed 's/.*://; s/[", ]//g'
    fi
}

#------------------------------------------------------------------------------#
#  1. Установка / удаление                                                      #
#------------------------------------------------------------------------------#
micro_installed() { have micro; }

micro_version() { micro --version 2>/dev/null | awk 'NR==1{print $2}'; }

install_micro() {
    print_header
    echo -ne "${YELLOW}"
    if micro_installed; then
        echo -e "${T[already_installed]} ${GREEN}$(micro_version)${RESET}"
        pause; return
    fi

    if have apt-get; then
        sudo apt-get update -qq && sudo apt-get install -y micro
    elif have dnf; then
        sudo dnf install -y micro
    elif have pacman; then
        sudo pacman -Sy --noconfirm micro
    elif have apk; then
        sudo apk add micro
    elif have zypper; then
        sudo zypper install -y micro
    elif have brew; then
        brew install micro
    elif have xbps-install; then
        sudo xbps-install -Sy micro
    else
        local tmp; tmp="$(mktemp -d)"
        curl https://getmic.ro | bash -s -- --DESTDIR="$tmp" || die "${T[die_download]}"
        sudo install -m 0755 "$tmp"/micro /usr/local/bin/micro
        rm -rf "$tmp"
    fi

    if micro_installed; then
        echo -e "${GREEN}${T[msg_installed]} $(micro_version)${YELLOW}"
    else
        echo -e "${RED}${T[msg_install_failed]}${YELLOW}"
    fi
    pause
}

remove_micro() {
    print_header
    echo -ne "${YELLOW}"
    if ! micro_installed; then
        echo "${T[not_installed]}"
        pause; return
    fi

    read -r -p "${T[ask_reset_editor]}" ans
    if [[ ! "${ans:-Y}" =~ ^[Nn]$ ]]; then
        select_default_editor
    fi

    mkdir -p "$BACKUP_DIR"
    [ -f "$SETTINGS" ] && cp "$SETTINGS" "$BACKUP_DIR/settings.json.$(date +%Y%m%d-%H%M%S)"

    if have apt-get;   then sudo apt-get remove -y micro
    elif have dnf;     then sudo dnf remove -y micro
    elif have pacman;  then sudo pacman -Rns --noconfirm micro
    elif have apk;     then sudo apk del micro
    elif have zypper;  then sudo zypper remove -y micro
    elif have brew;    then brew uninstall micro
    elif have xbps-install; then sudo xbps-remove micro
    else sudo rm -f /usr/local/bin/micro; fi

    if micro_installed; then
        echo -e "${RED}${T[msg_remove_failed]}${YELLOW}"
    else
        echo -e "${GREEN}${T[msg_removed_ok]} $BACKUP_DIR${YELLOW}"
    fi
    pause
}

menu_install() {
    print_header
    echo -ne "${YELLOW}"
    if micro_installed; then
        echo "${T[cur_version]} $(micro_version)"
        echo "${T[i_del_micro]}"
        echo "${T[back]}"
        read -r -p "${T[choice]}" c
        case "$c" in
            1) remove_micro ;;
            *) return ;;
        esac
    else
        echo "${T[i_install_micro]}"
        echo "${T[back]}"
        read -r -p "${T[choice]}" c
        case "$c" in
            1) install_micro ;;
            *) return ;;
        esac
    fi
}

#------------------------------------------------------------------------------#
#  2. Редактор по умолчанию                                                     #
#------------------------------------------------------------------------------#
# Текущий редактор по умолчанию: смотрим наши конфиги (fish/bash),
# а не $EDITOR окружения — иначе в fish-сессиях (Garuda и т.п.) скрипт
# показывает устаревшее значение из универсальных переменных fish.
current_editor() {
    local f v
    for f in "$HOME/.config/fish/config.fish" "$HOME/.config/fish/conf.d/micro-setup.fish" "$HOME/.profile" "$HOME/.bashrc"; do
        [ -f "$f" ] || continue
        v=$(sed -n \
            -e 's/.*set -[a-zA-Z]* *EDITOR *"\([^"]*\)".*/\1/p' \
            -e 's/.*set -[a-zA-Z]* *EDITOR *\([^" ]*\).*/\1/p' \
            -e 's/.*export EDITOR="\([^"]*\)".*/\1/p' "$f" | tail -1)
        [ -n "$v" ] && { basename "$v"; return; }
    done
    [ -n "${EDITOR:-}" ] && { basename "$EDITOR"; return; }
    echo ""
}

find_editors() {
    local -a found=()
    local e
    for e in micro nvim vim vi nano emacs pico joe kak helix hx ed; do
        have "$e" && found+=("$e")
    done
    printf '%s\n' "${found[@]}"
}

select_default_editor() {
    print_header
    echo -ne "${YELLOW}"
    mapfile -t editors < <(find_editors)
    if [ "${#editors[@]}" -eq 0 ]; then
        echo -e "${RED}${T[no_editors]}${YELLOW}"
        pause; return 1
    fi

    echo "${T[found_editors]}"
    local i=1 e cur; cur="$(current_editor)"
    for e in "${editors[@]}"; do
        local mark=""
        [ "$e" = "$cur" ] && mark="${T[cur_marker]}"
        printf "  %d) %s%s\n" "$i" "$e" "$mark"
        i=$((i+1))
    done

    read -r -p "${T[editor_number]}" n
    [[ -z "$n" ]] && return 1
    if ! [[ "$n" =~ ^[0-9]+$ ]] || [ "$n" -lt 1 ] || [ "$n" -gt "${#editors[@]}" ]; then
        echo -e "${RED}${T[no_such]}${RESET}"; pause; return 1
    fi

    local chosen="${editors[$((n-1))]}"
    local bin; bin="$(command -v "$chosen")"

    if have update-alternatives && [ "$(id -u)" -eq 0 ]; then
        update-alternatives --set editor "$bin" 2>/dev/null \
            && echo -e "${GREEN}✔ update-alternatives: $chosen${RESET}"
    elif have sudo && have update-alternatives && sudo -n true 2>/dev/null; then
        sudo update-alternatives --set editor "$bin" 2>/dev/null \
            && echo -e "${GREEN}✔ update-alternatives: $chosen${RESET}"
    fi

    local rc
    mkdir -p "$HOME"
    for rc in "$HOME/.bashrc" "$HOME/.profile"; do
        touch "$rc"
        sed -i '/# >>> micro-setup: default editor >>>/,/# <<< micro-setup: default editor <<</d' "$rc"
        sed -i '/^export EDITOR=/d; /^export VISUAL=/d' "$rc"
        cat >> "$rc" <<EOF

# >>> micro-setup: default editor >>>
export EDITOR="$bin"
export VISUAL="$bin"
# <<< micro-setup: default editor <<<
EOF
    done
    # fish (Garuda Sway и т.п.). Важно: fish читает conf.d РАНЬШЕ config.fish,
    # поэтому «голый» conf.d перекрывается строками из config.fish (у Garuda там
    # set -gx EDITOR nvim). Действуем так:
    #   1) стираем устаревшие универсальные переменные fish;
    #   2) ЗАМЕНЯЕМ существующие строки EDITOR/VISUAL в config.fish;
    #   3) если EDITOR там не упоминался — дописываем наш блок в конец;
    #   4) дублируем в conf.d как fallback.
    if have fish; then
        fish -c 'set -e EDITOR; set -e VISUAL' >/dev/null 2>&1 || true
        local fishcfg="$HOME/.config/fish/config.fish"
        mkdir -p "$(dirname "$fishcfg")"
        touch "$fishcfg"
        sed -i -E \
            -e "s|^set -[a-zA-Z]+ +EDITOR +.*|set -gx EDITOR $bin|" \
            -e "s|^set -[a-zA-Z]+ +VISUAL +.*|set -gx VISUAL $bin|" \
            "$fishcfg"
        if ! grep -qE '^set -[a-zA-Z]+ +EDITOR +' "$fishcfg"; then
            cat >> "$fishcfg" <<EOF

# >>> micro-setup: default editor >>>
set -gx EDITOR "$bin"
set -gx VISUAL "$bin"
# <<< micro-setup: default editor <<<
EOF
        fi
        local fishconf="$HOME/.config/fish/conf.d/micro-setup.fish"
        mkdir -p "$(dirname "$fishconf")"
        sed -i '/# >>> micro-setup: default editor >>>/,/# <<< micro-setup: default editor <<</d' "$fishconf" 2>/dev/null
        cat >> "$fishconf" <<EOF

# >>> micro-setup: default editor >>>
set -gx EDITOR "$bin"
set -gx VISUAL "$bin"
# <<< micro-setup: default editor <<<
EOF
        echo -e "${GREEN}${T[fish_updated]}${YELLOW}"
    fi

    export EDITOR="$bin" VISUAL="$bin"
    echo -e "${GREEN}✔ EDITOR/VISUAL → $bin${YELLOW}"
    pause
}

menu_editor() {
    select_default_editor
}

#------------------------------------------------------------------------------#
#  3. Буфер обмена (OSC 52 — копипаст через SSH)                                #
#------------------------------------------------------------------------------#
install_clip_tools() {
    if have xclip && have xsel; then return; fi
    if have apt-get; then
        sudo apt-get install -y xclip xsel >/dev/null 2>&1
    elif have dnf; then
        sudo dnf install -y xclip xsel >/dev/null 2>&1
    elif have pacman; then
        sudo pacman -Sy --noconfirm xclip xsel >/dev/null 2>&1
    fi
}

menu_clipboard() {
    print_header
    echo -ne "${YELLOW}"
    if ! micro_installed; then
        echo "${T[run_item1_first]}"
        pause; return
    fi

    local cur; cur="$(get_setting clipboard)"
    echo "${T[clipboard_cur]} ${cur:-${T[not_set]}}"
    echo "${T[clip_enable]}"
    echo "${T[clip_disable]}"
    echo "${T[back]}"
    read -r -p "${T[choice]}" c

    case "$c" in
        1)
            set_setting "clipboard" '"terminal"'
            install_clip_tools
            echo -e "${GREEN}${T[msg_clip_on]}${YELLOW}"
            ;;
        2)
            set_setting "clipboard" '"internal"'
            echo -e "${GREEN}${T[msg_clip_off]}${YELLOW}"
            ;;
        *) return ;;
    esac
    pause
}

#------------------------------------------------------------------------------#
#  Тумблеры и тема                                                              #
#------------------------------------------------------------------------------#
toggle_setting() {
    local key="$1" title="$2"
    local cur; cur="$(get_setting "$key")"
    # нормализуем старые строковые значения ("true"/"false") → булевы
    case "$cur" in
        '"true"'|true)  cur="true" ;;
        '"false"'|false) cur="false" ;;
    esac
    local new="true"
    [ "$cur" = "true" ] && new="false"
    # булево пишем БЕЗ кавычек — иначе micro ругается "incorrect type (string)"
    set_setting "$key" "$new"
    MSG="✔ $title: $new"
}

list_themes() {
    cat <<'EOF'
default
solarized
solarized-tc
monokai
monokai-dark
zenburn
gruvbox
gruvbox-tc
twilight
darcula
geany
atom-dark
one-dark
railscast
simple
EOF
    local d="$HOME/.config/micro/colorschemes"
    [ -d "$d" ] && find "$d" -maxdepth 1 -name '*.micro' -printf '%f\n' 2>/dev/null | sed 's/\.micro$//'
}

menu_theme() {
    print_header
    echo -ne "${YELLOW}"
    mapfile -t themes < <(list_themes | awk '!seen[$0]++')
    local cur; cur="$(get_setting colorscheme)"
    local i=1 t
    for t in "${themes[@]}"; do
        local mark=""
        [ "$t" = "$cur" ] && mark="${T[cur_marker]}"
        printf "  %2d) %-16s%s\n" "$i" "$t" "$mark"
        i=$((i+1))
    done
    echo "${T[enter_theme_name]}"
    echo "   0) ${T[m0]}"
    read -r -p "${T[choice]}" n
    [[ -z "$n" || "$n" = "0" ]] && return
    if [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le "${#themes[@]}" ]; then
        set_setting "colorscheme" "\"${themes[$((n-1))]}\""
        MSG="${T[msg_theme]} ${themes[$((n-1))]}"
    else
        read -r -p "${T[theme_name]}" tname
        if [ -n "$tname" ]; then
            set_setting "colorscheme" "\"$tname\""
            MSG="${T[msg_theme]} $tname"
        fi
    fi
}

#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
#  .desktop-файл: открытие файлов через micro в конкретном терминале            #
#------------------------------------------------------------------------------#
# Проблема: штатный micro.desktop содержит Terminal=true, и xdg-open пытается
# найти «терминал по умолчанию» через портал/xdg-terminal-exec. Если он не
# настроен (Sway и др.), вылезает «Не удалось найти терминал, требуемый для
# приложения». Решение: свой micro.desktop с Terminal=false и显式
# запуском нужного терминала (foot и т.д.).
detect_terminals() {
    # формат вывода: имя<TAB>команда запуска
    [ -n "${TERMINAL:-}" ] && printf '%s\t%s\n' "$TERMINAL" "$TERMINAL micro %F"
    local name cmd
    while IFS='|' read -r name cmd; do
        have "$name" && printf '%s\t%s\n' "$name" "$cmd"
    done <<'EOF'
foot|foot micro %F
kitty|kitty micro %F
ghostty|ghostty -e micro %F
alacritty|alacritty -e micro %F
wezterm|wezterm start -- micro %F
kgx|kgx -e micro %F
gnome-terminal|gnome-terminal -- micro %F
konsole|konsole -e micro %F
xfce4-terminal|xfce4-terminal -x micro %F
lxterminal|lxterminal -e micro %F
tilix|tilix -e micro %F
terminator|terminator -e micro %F
xterm|xterm -e micro %F
EOF
}

menu_desktop() {
    print_header
    echo -ne "${YELLOW}"
    if ! micro_installed; then
        echo "${T[run_item1_first]}"
        pause; return
    fi

    mapfile -t terms < <(detect_terminals | awk -F'\t' '!seen[$1]++')
    local term_cmd=""

    if [ "${#terms[@]}" -eq 0 ]; then
        echo "${T[no_term_found]}"
        read -r -p "${T[term_cmd_prompt]}" term_cmd
        [ -z "$term_cmd" ] && return
    else
        echo "${T[found_terminals]}"
        local i=1 t
        for t in "${terms[@]}"; do
            printf "  %d) %s\n" "$i" "${t%%$'\t'*}"
            i=$((i+1))
        done
        echo "${T[enter_manually]}"
        echo "${T[cancel]}"
        read -r -p "${T[which_term]}" n
        case "${n:-1}" in
            0) return ;;
            *[!0-9]*|"")
                read -r -p "${T[launch_cmd]}" term_cmd ;;
            *)
                if [ "$n" -ge 1 ] && [ "$n" -le "${#terms[@]}" ]; then
                    term_cmd="${terms[$((n-1))]#*$'\t'}"
                else
                    read -r -p "${T[launch_cmd]}" term_cmd
                fi ;;
        esac
        [ -z "$term_cmd" ] && return
    fi

    local appdir="$HOME/.local/share/applications"
    mkdir -p "$appdir"
    cat > "$appdir/micro.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=micro
GenericName=Text Editor
Comment=Edit text files in a terminal
Exec=$term_cmd
Icon=micro
Terminal=false
Categories=Utility;TextEditor;Development;
Keywords=text;editor;terminal;cli;
MimeType=text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-python;text/x-perl;text/x-shellscript;text/x-markdown;text/html;text/xml;text/css;text/javascript;application/json;
StartupNotify=false
EOF
    chmod 644 "$appdir/micro.desktop"

    # ассоциация text/plain и обновление кэша desktop-файлов
    have xdg-mime && xdg-mime default micro.desktop text/plain 2>/dev/null
    if have update-desktop-database; then
        update-desktop-database "$appdir" 2>/dev/null
    fi

    echo -e "${GREEN}${T[msg_desktop]}: $appdir/micro.desktop${YELLOW}"
    echo -e "${GREEN}  Exec=$term_cmd${YELLOW}"
    MSG="${T[msg_desktop]} ($term_cmd)"
}

#------------------------------------------------------------------------------#
#  Файловые менеджеры: редактор по умолчанию                                    #
#------------------------------------------------------------------------------#
find_filemanagers() {
    local fm
    for fm in ranger mc vifm nnn lf yazi xplr joshuto broot; do
        have "$fm" && echo "$fm"
    done
}

# Показывает список установленных редакторов и возвращает путь к выбранному.
# Без побочных эффектов. rc=1 — отмена.
ask_editor() {
    mapfile -t editors < <(find_editors)
    if [ "${#editors[@]}" -eq 0 ]; then
        echo -e "${RED}  ${T[no_editors]}${RESET}" >&2
        return 1
    fi
    # меню — в stderr, чтобы stdout остался чистым для результата
    echo "${T[found_editors]}" >&2
    local i=1 e cur; cur="$(current_editor)"
    for e in "${editors[@]}"; do
        local mark=""
        [ "$e" = "$cur" ] && mark="${T[cur_default_marker]}"
        printf "  %d) %s%s\n" "$i" "$e" "$mark" >&2
        i=$((i+1))
    done
    read -r -p "  ${T[editor_number]}" n
    [[ -z "$n" ]] && return 1
    if ! [[ "$n" =~ ^[0-9]+$ ]] || [ "$n" -lt 1 ] || [ "$n" -gt "${#editors[@]}" ]; then
        echo -e "${RED}  ${T[no_such]}${RESET}" >&2
        return 1
    fi
    command -v "${editors[$((n-1))]}"
}

# ranger: правило в rifle.conf (первое совпадение выигрывает)
setup_ranger() {
    local editor="$1"
    local rdir="$CONFIG_HOME/ranger"
    local rfile="$rdir/rifle.conf"
    mkdir -p "$rdir"
    if [ ! -f "$rfile" ]; then
        local sys
        for sys in /usr/share/ranger/config/rifle.conf /usr/local/share/ranger/config/rifle.conf; do
            [ -f "$sys" ] && cp "$sys" "$rfile" && break
        done
        [ -f "$rfile" ] || touch "$rfile"
    fi
    # Убираем только НАШИ старые правила (с абсолютным путём редактора) —
    # и помеченные label editor (прошлая версия скрипта), и безметочные.
    # Штатные правила rifle (с \${VISUAL:-\$EDITOR} и т.п.) не трогаем.
    grep -v -E '^mime \^text(, label editor)? = /[^ ]+ -- ' "$rfile" > "$rfile.tmp"
    # БЕЗМЕТОЧНОЕ правило: срабатывает при любом способе открытия (Enter, l, E).
    # Помеченные правила (label editor) rifle применяет только по E / open_with —
    # поэтому пометка здесь не подходит.
    { echo "mime ^text = $editor -- \"\$@\""; cat "$rfile.tmp"; } > "$rfile"
    rm -f "$rfile.tmp"
}

# mc: внешний редактор вместо встроенного (сам редактор mc берёт из $EDITOR)
setup_mc() {
    local mcini="$CONFIG_HOME/mc/ini"
    [ -d "$(dirname "$mcini")" ] || mcini="$HOME/.config/mc/ini"
    mkdir -p "$(dirname "$mcini")"
    if [ -f "$mcini" ]; then
        if grep -q '^use_internal_edit=' "$mcini"; then
            sed -i 's/^use_internal_edit=.*/use_internal_edit=0/' "$mcini"
        elif grep -q '^\[Misc\]' "$mcini"; then
            sed -i '/^\[Misc\]/a use_internal_edit=0' "$mcini"
        else
            printf '[Misc]\nuse_internal_edit=0\n' >> "$mcini"
        fi
    else
        printf '[Misc]\nuse_internal_edit=0\n' > "$mcini"
    fi
}

# vifm: set vicmd=<editor>
setup_vifm() {
    local editor="$1"
    local conf="$CONFIG_HOME/vifm/vifmrc"
    mkdir -p "$(dirname "$conf")"
    touch "$conf"
    sed -i '/^set vicmd=/d' "$conf"
    echo "set vicmd=$editor" >> "$conf"
}

menu_filemanagers() {
    print_header
    echo -ne "${YELLOW}"
    mapfile -t fms < <(find_filemanagers)
    if [ "${#fms[@]}" -eq 0 ]; then
        echo "${T[no_fms]}"
        pause; return
    fi

    echo "${T[found_fms]}"
    local i=1 fm
    for fm in "${fms[@]}"; do
        printf "  %d) %s\n" "$i" "$fm"
        i=$((i+1))
    done
    read -r -p "${T[which_fm]}" n
    [[ -z "$n" ]] && return
    if ! [[ "$n" =~ ^[0-9]+$ ]] || [ "$n" -lt 1 ] || [ "$n" -gt "${#fms[@]}" ]; then
        echo -e "${RED}  ${T[no_such]}${RESET}"; pause; return
    fi
    fm="${fms[$((n-1))]}"

    local editor
    if ! editor="$(ask_editor)"; then
        pause; return
    fi

    case "$fm" in
        ranger)
            setup_ranger "$editor"
            MSG="${T[msg_ranger]} $editor"
            ;;
        mc)
            setup_mc
            echo -e "  ${GREEN}${T[msg_mc_builtin_off]}${RESET}"
            echo -e "  ${YELLOW}${T[mc_external_note]}${RESET}"
            read -r -p "  ${T[ask_mc_system]//@EDITOR@/$editor}" a
            if [[ ! "${a:-Y}" =~ ^[Nn]$ ]]; then
                select_default_editor
                MSG="${T[msg_mc_via]//@EDITOR@/$editor}"
            else
                MSG="${T[msg_mc_external]}"
            fi
            ;;
        vifm)
            setup_vifm "$editor"
            MSG="${T[msg_vifm]} $editor"
            ;;
        *)
            echo -e "  ${YELLOW}$fm ${T[fm_ed_note]}${RESET}"
            MSG="→ $fm ${T[msg_fm_uses_editor]}"
            pause
            ;;
    esac
}

#------------------------------------------------------------------------------#
#  Уборка старых кастомных ярлыков «(Foot)»                                     #
#------------------------------------------------------------------------------#
find_foot_desktops() {
    local dir
    for dir in "$HOME/.local/share/applications" /usr/local/share/applications /usr/share/applications; do
        [ -d "$dir" ] || continue
        grep -ils "(Foot)" "$dir"/*.desktop 2>/dev/null
    done
}

menu_cleanup_foot() {
    mapfile -t files < <(find_foot_desktops)
    if [ "${#files[@]}" -eq 0 ]; then
        echo "${T[no_foot]}"
        pause; return
    fi
    echo "${T[found_legacy]}"
    local f
    for f in "${files[@]}"; do
        local name; name=$(grep -m1 '^Name=' "$f" 2>/dev/null | cut -d= -f2-)
        echo "   • $f ${name:+($name)}"
    done
    echo
    read -r -p "${T[ask_delete]}" a
    [[ "${a:-Y}" =~ ^[Nn]$ ]] && return

    local removed=0 cur
    cur=$(xdg-mime query default text/plain 2>/dev/null)
    for f in "${files[@]}"; do
        case "$f" in
            "$HOME"/*) rm -f "$f" && removed=$((removed+1)) ;;
            *)  sudo rm -f "$f" && removed=$((removed+1)) ;;
        esac
        # если удалённый ярлык был дефолтным для text/plain — назначаем micro
        [ "$(basename "$f")" = "$cur" ] && have xdg-mime \
            && xdg-mime default micro.desktop text/plain 2>/dev/null
    done
    for f in "$HOME/.local/share/applications" /usr/local/share/applications /usr/share/applications; do
        [ -d "$f" ] && have update-desktop-database && update-desktop-database "$f" 2>/dev/null
    done
    echo -e "  ${GREEN}${T[removed]} $removed${YELLOW}"
    MSG="${T[msg_removed]} $removed"
    pause
}

#------------------------------------------------------------------------------#
#  Главное меню (все пункты в один уровень)                                     #
#------------------------------------------------------------------------------#
main_menu() {
    print_header
    echo -ne "${YELLOW}"
    local a
    local cured; cured="$(current_editor)"
    [ -z "$cured" ] && cured="—"
    if micro_installed; then
        echo -e "  micro ${GREEN}$(micro_version)${YELLOW} — ${T[m_installed]}    ${T[default_editor]} $cured"
    else
        echo -e "  ${T[m_not_installed]}    ${T[default_editor]} $cured"
    fi
    echo
    echo "  1. ${T[m1]}"
    echo "  2. ${T[m2]}"
    echo "  3. ${T[m3]}"
    a="$(get_setting autosave)";        echo "  4. ${T[m4]} ${a:-false}"
    a="$(get_setting mouse)";           echo "  5. ${T[m5]} ${a:-false}"
    a="$(get_setting statusline)";      echo "  6. ${T[m6]} ${a:-true}"
    a="$(get_setting ruler)";           echo "  7. ${T[m7]} ${a:-true}"
    a="$(get_setting tabstospaces)";    echo "  8. ${T[m8]} ${a:-false}"
    a="$(get_setting softwrap)";        echo "  9. ${T[m9]} ${a:-true}"
    a="$(get_setting autosu)";          echo " 10. ${T[m10]} ${a:-false}"
    a="$(get_setting keepautoindent)";  echo " 11. ${T[m11]} ${a:-false}"
    echo   " 12. ${T[m12]} $(get_setting colorscheme)"
    local dsk="$HOME/.local/share/applications/micro.desktop"
    if [ -f "$dsk" ]; then
        echo   " 13. ${T[m13]} ${T[st_created]}"
    else
        echo   " 13. ${T[m13]} ${T[st_none]}"
    fi
    local fmst="${T[st_no]}"
    { { [ -f "$CONFIG_HOME/mc/ini" ] && grep -q '^use_internal_edit=0' "$CONFIG_HOME/mc/ini"; } \
      || { [ -f "$CONFIG_HOME/ranger/rifle.conf" ] && grep -qE '^mime \^text(, label editor)? = /' "$CONFIG_HOME/ranger/rifle.conf"; } \
      || { [ -f "$CONFIG_HOME/vifm/vifmrc" ] && grep -q '^set vicmd=' "$CONFIG_HOME/vifm/vifmrc"; }; } \
      && fmst="${T[st_yes]}"
    echo   " 14. ${T[m14]} $fmst"
    echo   " 15. ${T[m15]}"
    echo   " 16. ${T[m16]}"
    echo   "  0. ${T[m0]}"
    echo
    [ -n "$MSG" ] && echo -e "  ${GREEN}$MSG${YELLOW}"
    echo
    MSG=""
}

#------------------------------------------------------------------------------#
#  Миграция: строковые "true"/"false" -> булевы (чинит settings.json от старых  #
#  версий скрипта, иначе micro ругается "incorrect type (string)")              #
#------------------------------------------------------------------------------#
normalize_settings() {
    [ -f "$SETTINGS" ] || return 0
    if have jq; then
        jq 'to_entries
            | map(if .value == "true" then .value = true
                  elif .value == "false" then .value = false
                  else . end)
            | from_entries' "$SETTINGS" > "$SETTINGS.tmp" 2>/dev/null \
            && mv "$SETTINGS.tmp" "$SETTINGS"
    elif have python3; then
        python3 - "$SETTINGS" <<'PYEOF'
import json, sys, os
path = sys.argv[1]
try:
    with open(path) as f:
        data = json.load(f)
except Exception:
    sys.exit(0)
changed = False
for k, v in data.items():
    if v == "true":
        data[k] = True;  changed = True
    elif v == "false":
        data[k] = False; changed = True
if changed:
    tmp = path + ".tmp"
    with open(tmp, "w") as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
    os.replace(tmp, path)
PYEOF
    fi
}

#------------------------------------------------------------------------------#
#  Точка входа                                                                  #
#------------------------------------------------------------------------------#
[ -t 0 ] || die "${T[die_tty]}"

normalize_settings

while true; do
    main_menu
    read -r -p "${T[choice]}" choice
    case "$choice" in
        1) menu_install ;;
        2) menu_editor ;;
        3) menu_clipboard ;;
        4) toggle_setting "autosave"       "${T[m4]}" ;;
        5) toggle_setting "mouse"          "${T[m5]}" ;;
        6) toggle_setting "statusline"     "${T[m6]}" ;;
        7) toggle_setting "ruler"          "${T[m7]}" ;;
        8) toggle_setting "tabstospaces"   "${T[m8]}" ;;
        9) toggle_setting "softwrap"       "${T[m9]}" ;;
        10) toggle_setting "autosu"         "${T[m10]}" ;;
        11) toggle_setting "keepautoindent" "${T[m11]}" ;;
        12) menu_theme ;;
        13) menu_desktop ;;
        14) menu_filemanagers ;;
        15) menu_cleanup_foot ;;
        16) toggle_language ;;
        0) echo -ne "${RESET}"; exit 0 ;;
        *) echo -e "${RED}${T[no_such]}${RESET}"; sleep 1 ;;
    esac
done
