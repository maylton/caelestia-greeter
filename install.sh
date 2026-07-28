#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

VERSION="1.0.0"
PROJECT_NAME="Caelestia Greeter"
INSTALL_DIR="/etc/xdg/quickshell/caelestia-greeter"
BACKUP_BASE="/var/backups/caelestia-greeter"
CACHE_DIR="/var/cache/caelestia-greeter"
RUNTIME_DIR="/run/caelestia-greeter"
SYSTEMD_DROPIN_DIR="/etc/systemd/system/greetd.service.d"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSUME_YES=0
TARGET_USER=""
CONFIGURE_KEYRING=1
LANGUAGE=""

usage() {
    cat <<USAGE
$PROJECT_NAME installer $VERSION

Usage: ./install.sh [options]

Options:
  --user USER          Use USER's Caelestia profile for wallpaper, palette,
                       avatar, shell configuration and font synchronization.
  --yes                Accept the installation plan without an interactive prompt.
  --no-keyring         Do not add GNOME Keyring PAM integration to greetd.
  --lang pt-BR|en      Installer language. Defaults to the current locale.
  -h, --help           Show this help.
USAGE
}

while (($#)); do
    case "$1" in
        --user)
            [[ $# -ge 2 ]] || { printf 'Missing value for --user.\n' >&2; exit 2; }
            TARGET_USER="$2"
            shift 2
            ;;
        --yes)
            ASSUME_YES=1
            shift
            ;;
        --no-keyring)
            CONFIGURE_KEYRING=0
            shift
            ;;
        --lang)
            [[ $# -ge 2 ]] || { printf 'Missing value for --lang.\n' >&2; exit 2; }
            LANGUAGE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'Unknown option: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if [[ -z "$LANGUAGE" ]]; then
    locale_value="${LC_ALL:-${LC_MESSAGES:-${LANG:-en}}}"
    if [[ "${locale_value,,}" == pt* ]]; then
        LANGUAGE="pt-BR"
    else
        LANGUAGE="en"
    fi
fi

if [[ "$LANGUAGE" != "pt-BR" && "$LANGUAGE" != "en" ]]; then
    printf 'Unsupported language: %s\n' "$LANGUAGE" >&2
    exit 2
fi

if [[ "$LANGUAGE" == "pt-BR" ]]; then
    T_TITLE="Instalador do Caelestia Greeter"
    T_ROOT="São necessários privilégios administrativos. Solicitando sudo..."
    T_ERROR="A instalação falhou na etapa"
    T_DETECT="Detectando usuário e gerenciador de login atual"
    T_VALIDATE="Validando dependências e arquivos do projeto"
    T_PLAN="Plano de instalação"
    T_CURRENT_DM="Gerenciador de login detectado"
    T_NO_DM="Nenhum gerenciador de login ativo foi detectado"
    T_TARGET_USER="Perfil do Caelestia usado"
    T_BACKUP_EXPLAIN="Será criado um backup dos arquivos e do estado do gerenciador atual"
    T_DISABLE_EXPLAIN="O gerenciador atual será desativado para o próximo boot; ele NÃO será interrompido nesta sessão"
    T_INSTALL_EXPLAIN="Os arquivos QML, scripts, configuração do Hyprland e configuração do greetd serão instalados"
    T_CACHE_EXPLAIN="Avatar, wallpaper, paleta, configuração do Shell e fonte serão copiados para um cache legível pelo usuário restrito do greetd"
    T_PAM_EXPLAIN="A integração PAM do GNOME Keyring será configurada quando o módulo estiver disponível"
    T_ENABLE_EXPLAIN="O greetd será habilitado como gerenciador de login padrão para o próximo boot"
    T_RESTORE_EXPLAIN="Um comando de restauração será instalado para reativar o gerenciador anterior"
    T_CONFIRM="Digite INSTALAR para continuar"
    T_CANCEL="Instalação cancelada. Nenhuma alteração foi realizada."
    T_BACKUP="Criando backup do gerenciador atual e da instalação existente"
    T_INSTALL_FILES="Instalando os arquivos do Caelestia Greeter"
    T_PAM="Configurando autenticação e GNOME Keyring"
    T_SYNC="Sincronizando perfil, wallpaper, paleta e fonte"
    T_SWITCH="Configurando a troca de gerenciador de login"
    T_DONE="Instalação concluída"
    T_REBOOT="Salve seu trabalho e reinicie o computador para testar o novo greeter"
    T_BACKUP_PATH="Backup salvo em"
    T_RESTORE_CMD="Para restaurar o gerenciador anterior a partir de uma TTY"
    T_WARN_FONT="A fonte variável do Caelestia não foi encontrada. O relógio poderá usar uma fonte de fallback."
    T_WARN_M3="O módulo M3Shapes não foi encontrado. Os glyphs da senha usarão círculos simples."
    T_WARN_CONFIG="A configuração do Caelestia Shell não foi encontrada; serão usados os valores padrão disponíveis."
    T_MISSING="Dependência obrigatória ausente"
else
    T_TITLE="Caelestia Greeter installer"
    T_ROOT="Administrative privileges are required. Requesting sudo..."
    T_ERROR="Installation failed during step"
    T_DETECT="Detecting the target user and current login manager"
    T_VALIDATE="Validating dependencies and project files"
    T_PLAN="Installation plan"
    T_CURRENT_DM="Detected login manager"
    T_NO_DM="No active login manager was detected"
    T_TARGET_USER="Caelestia profile used"
    T_BACKUP_EXPLAIN="A backup of the current manager's files and service state will be created"
    T_DISABLE_EXPLAIN="The current manager will be disabled for the next boot; it will NOT be stopped in this session"
    T_INSTALL_EXPLAIN="The QML files, scripts, Hyprland configuration and greetd configuration will be installed"
    T_CACHE_EXPLAIN="Avatar, wallpaper, palette, Shell configuration and font will be copied to a cache readable by greetd's restricted user"
    T_PAM_EXPLAIN="GNOME Keyring PAM integration will be configured when the module is available"
    T_ENABLE_EXPLAIN="greetd will be enabled as the default login manager for the next boot"
    T_RESTORE_EXPLAIN="A restore command will be installed to reactivate the previous manager"
    T_CONFIRM="Type INSTALL to continue"
    T_CANCEL="Installation cancelled. No changes were made."
    T_BACKUP="Backing up the current login manager and existing installation"
    T_INSTALL_FILES="Installing Caelestia Greeter files"
    T_PAM="Configuring authentication and GNOME Keyring"
    T_SYNC="Synchronizing the profile, wallpaper, palette and font"
    T_SWITCH="Configuring the login-manager switch"
    T_DONE="Installation completed"
    T_REBOOT="Save your work and reboot the computer to test the new greeter"
    T_BACKUP_PATH="Backup saved at"
    T_RESTORE_CMD="To restore the previous manager from a TTY"
    T_WARN_FONT="The Caelestia variable font was not found. The clock may use a fallback font."
    T_WARN_M3="The M3Shapes module was not found. Password glyphs will use simple circles."
    T_WARN_CONFIG="The Caelestia Shell configuration was not found; available defaults will be used."
    T_MISSING="Required dependency is missing"
fi

bold() { printf '\033[1m%s\033[0m' "$*"; }
info() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

CURRENT_STEP="startup"
on_error() {
    local exit_code=$?
    printf '\n\033[1;31m%s: %s (exit %d).\033[0m\n' "$T_ERROR" "$CURRENT_STEP" "$exit_code" >&2
    if [[ -n "${BACKUP_DIR:-}" ]]; then
        printf '%s: %s\n' "$T_BACKUP_PATH" "$BACKUP_DIR" >&2
    fi
    exit "$exit_code"
}
trap on_error ERR

if ((EUID != 0)); then
    printf '%s\n' "$T_ROOT"
    sudo_args=(--lang "$LANGUAGE")
    [[ -n "$TARGET_USER" ]] && sudo_args+=(--user "$TARGET_USER")
    ((ASSUME_YES)) && sudo_args+=(--yes)
    ((CONFIGURE_KEYRING == 0)) && sudo_args+=(--no-keyring)
    exec sudo -- "$SCRIPT_DIR/install.sh" "${sudo_args[@]}"
fi

require_command() {
    command -v "$1" >/dev/null 2>&1 || die "$T_MISSING: $1"
}

is_regular_user() {
    local user="$1" uid shell
    IFS=: read -r _ _ uid _ _ _ shell < <(getent passwd "$user") || return 1
    [[ "$uid" =~ ^[0-9]+$ ]] || return 1
    ((uid >= 1000 && uid < 60000)) || return 1
    [[ ! "$shell" =~ (nologin|false)$ ]]
}

detect_target_user() {
    if [[ -n "$TARGET_USER" ]]; then
        is_regular_user "$TARGET_USER" || die "Invalid target user: $TARGET_USER"
        return
    fi

    if [[ -n "${SUDO_USER:-}" && "$SUDO_USER" != "root" ]] && is_regular_user "$SUDO_USER"; then
        TARGET_USER="$SUDO_USER"
        return
    fi

    while IFS=: read -r name _ uid _ _ _ shell; do
        [[ "$uid" =~ ^[0-9]+$ ]] || continue
        ((uid >= 1000 && uid < 60000)) || continue
        [[ ! "$shell" =~ (nologin|false)$ ]] || continue
        TARGET_USER="$name"
        return
    done < <(getent passwd)

    die "No regular local user was found. Use --user USER."
}

detect_display_manager() {
    local target service
    if [[ -L /etc/systemd/system/display-manager.service ]]; then
        target="$(readlink -f /etc/systemd/system/display-manager.service || true)"
        service="$(basename -- "$target")"
        if [[ -n "$service" ]]; then
            printf '%s' "$service"
            return
        fi
    fi

    for service in sddm.service gdm.service gdm3.service lightdm.service greetd.service ly.service lxdm.service; do
        if systemctl is-active --quiet "$service" 2>/dev/null || systemctl is-enabled --quiet "$service" 2>/dev/null; then
            printf '%s' "$service"
            return
        fi
    done
}

dm_label() {
    case "$1" in
        sddm.service) printf 'SDDM' ;;
        gdm.service|gdm3.service) printf 'GDM' ;;
        lightdm.service) printf 'LightDM' ;;
        greetd.service) printf 'greetd' ;;
        ly.service) printf 'Ly' ;;
        lxdm.service) printf 'LXDM' ;;
        '') printf '%s' "$T_NO_DM" ;;
        *) printf '%s' "$1" ;;
    esac
}

path_exists() {
    [[ -e "$1" || -L "$1" ]]
}

backup_path() {
    local path="$1" relative destination
    path_exists "$path" || return 0
    relative="${path#/}"
    destination="$BACKUP_DIR/files/$relative"
    mkdir -p -- "$(dirname -- "$destination")"
    cp -a -- "$path" "$destination"
    printf '%s\n' "$path" >> "$BACKUP_DIR/backed-up-paths.txt"
}

backup_sddm_theme() {
    local theme="" file
    local files=()
    path_exists /etc/sddm.conf && files+=(/etc/sddm.conf)
    if [[ -d /etc/sddm.conf.d ]]; then
        while IFS= read -r -d '' file; do files+=("$file"); done < <(find /etc/sddm.conf.d -maxdepth 1 -type f -name '*.conf' -print0 2>/dev/null)
    fi
    if ((${#files[@]})); then
        theme="$(awk -F= '/^[[:space:]]*Current[[:space:]]*=/{gsub(/[[:space:]]/, "", $2); value=$2} END{print value}' "${files[@]}" 2>/dev/null || true)"
    fi
    if [[ -n "$theme" && -d "/usr/share/sddm/themes/$theme" ]]; then
        backup_path "/usr/share/sddm/themes/$theme"
    fi
}

collect_backup() {
    local generic_paths=(
        /etc/systemd/system/display-manager.service
        /etc/pam.d/greetd
        /etc/greetd
        /etc/xdg/quickshell/caelestia-greeter
        /etc/systemd/system/greetd.service.d
        /usr/local/bin/caelestia-greeter-session
        /usr/local/bin/caelestia-greeter-run
        /usr/local/bin/caelestia-greeter-compositor
        /usr/local/bin/caelestia-greeter-profile-sync
        /usr/local/bin/caelestia-greeter-restore
        /usr/local/bin/caelestia-session
    )
    local path
    for path in "${generic_paths[@]}"; do backup_path "$path"; done

    case "$CURRENT_DM_SERVICE" in
        sddm.service)
            backup_path /etc/sddm.conf
            backup_path /etc/sddm.conf.d
            backup_path /var/lib/sddm/state.conf
            backup_sddm_theme
            ;;
        gdm.service|gdm3.service)
            backup_path /etc/gdm
            backup_path /etc/gdm3
            ;;
        lightdm.service)
            backup_path /etc/lightdm
            ;;
        greetd.service)
            backup_path /etc/greetd
            ;;
        ly.service)
            backup_path /etc/ly
            ;;
        lxdm.service)
            backup_path /etc/lxdm
            ;;
    esac
}

find_google_sans_flex() {
    local home="$1" candidate
    local candidates=(
        "$home/.config/quickshell/caelestia/assets/google-sans-flex/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf"
        "/etc/xdg/quickshell/caelestia/assets/google-sans-flex/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf"
        "/usr/share/quickshell/caelestia/assets/google-sans-flex/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf"
    )
    for candidate in "${candidates[@]}"; do
        if [[ -r "$candidate" ]]; then
            printf '%s' "$candidate"
            return
        fi
    done
}

validate_project_files() {
    local required=(
        assets components config design i18n services shell.qml
        scripts/caelestia-greeter-session
        scripts/caelestia-greeter-run
        scripts/caelestia-greeter-compositor
        scripts/caelestia-greeter-profile-sync
        scripts/caelestia-greeter-restore
        scripts/caelestia-session
        packaging/greetd/caelestia-greeter-hyprland.conf
        packaging/greetd/config.toml
        packaging/systemd/greetd-caelestia-greeter.conf
    )
    local entry
    for entry in "${required[@]}"; do
        path_exists "$SCRIPT_DIR/$entry" || die "Missing project file: $entry"
    done
}

configure_pam_keyring() {
    local pam_file=/etc/pam.d/greetd module_found=0
    for module in /usr/lib/security/pam_gnome_keyring.so /usr/lib64/security/pam_gnome_keyring.so /usr/lib/x86_64-linux-gnu/security/pam_gnome_keyring.so; do
        [[ -e "$module" ]] && module_found=1 && break
    done

    if ((CONFIGURE_KEYRING == 0 || module_found == 0)); then
        ((module_found == 0)) && warn "pam_gnome_keyring.so not found; keyring integration was skipped."
        return
    fi

    if [[ ! -e "$pam_file" ]]; then
        cat > "$pam_file" <<'PAM'
#%PAM-1.0
auth       include      system-local-login
account    include      system-local-login
session    include      system-local-login
password   include      system-local-login
PAM
    fi

    grep -Eq '^[[:space:]]*auth[[:space:]]+optional[[:space:]]+pam_gnome_keyring\.so([[:space:]]|$)' "$pam_file" \
        || printf '\nauth optional pam_gnome_keyring.so\n' >> "$pam_file"
    grep -Eq '^[[:space:]]*session[[:space:]]+optional[[:space:]]+pam_gnome_keyring\.so([[:space:]]|$)' "$pam_file" \
        || printf 'session optional pam_gnome_keyring.so auto_start\n' >> "$pam_file"
    chmod 0644 "$pam_file"
}

install_project() {
    local staging="${INSTALL_DIR}.new.$$" script
    rm -rf -- "$staging"
    install -d -m 0755 "$staging"
    cp -a -- \
        "$SCRIPT_DIR/assets" \
        "$SCRIPT_DIR/components" \
        "$SCRIPT_DIR/config" \
        "$SCRIPT_DIR/design" \
        "$SCRIPT_DIR/i18n" \
        "$SCRIPT_DIR/services" \
        "$SCRIPT_DIR/shell.qml" \
        "$staging/"
    chown -R root:root "$staging"
    find "$staging" -type d -exec chmod 0755 {} +
    find "$staging" -type f -exec chmod 0644 {} +
    rm -rf -- "$INSTALL_DIR"
    mv -- "$staging" "$INSTALL_DIR"

    for script in \
        caelestia-greeter-session \
        caelestia-greeter-run \
        caelestia-greeter-compositor \
        caelestia-greeter-profile-sync \
        caelestia-greeter-restore \
        caelestia-session; do
        install -Dm0755 "$SCRIPT_DIR/scripts/$script" "/usr/local/bin/$script"
    done

    install -Dm0644 "$SCRIPT_DIR/packaging/greetd/caelestia-greeter-hyprland.conf" \
        /etc/greetd/caelestia-greeter-hyprland.conf
    install -Dm0644 "$SCRIPT_DIR/packaging/greetd/config.toml" \
        /etc/greetd/config.toml
    install -Dm0644 "$SCRIPT_DIR/packaging/systemd/greetd-caelestia-greeter.conf" \
        "$SYSTEMD_DROPIN_DIR/caelestia-greeter.conf"
}

printf '\n'
bold "$T_TITLE $VERSION"
printf '\n\n'

CURRENT_STEP="$T_DETECT"
info "$CURRENT_STEP"
require_command systemctl
require_command getent
require_command install
require_command find
require_command awk
require_command grep
require_command qs
if ! command -v Hyprland >/dev/null 2>&1 && ! command -v start-hyprland >/dev/null 2>&1; then
    die "$T_MISSING: Hyprland"
fi
if ! command -v greetd >/dev/null 2>&1 && ! systemctl cat greetd.service >/dev/null 2>&1; then
    die "$T_MISSING: greetd"
fi

detect_target_user
CURRENT_DM_SERVICE="$(detect_display_manager)"
CURRENT_DM_LABEL="$(dm_label "$CURRENT_DM_SERVICE")"
TARGET_PASSWD="$(getent passwd "$TARGET_USER")"
IFS=: read -r _ _ TARGET_UID TARGET_GID _ TARGET_HOME _ <<< "$TARGET_PASSWD"
TARGET_HOME="${TARGET_HOME:-/home/$TARGET_USER}"

CURRENT_STEP="$T_VALIDATE"
info "$CURRENT_STEP"
validate_project_files
for script in "$SCRIPT_DIR"/scripts/*; do
    [[ -f "$script" ]] && bash -n "$script"
done

SHELL_CONFIG="$TARGET_HOME/.config/caelestia/shell.json"
FONT_SOURCE="$(find_google_sans_flex "$TARGET_HOME")"
[[ -n "$FONT_SOURCE" ]] || warn "$T_WARN_FONT"
[[ -r "$SHELL_CONFIG" ]] || warn "$T_WARN_CONFIG"
if [[ ! -e /usr/lib/qt6/qml/M3Shapes/qmldir && ! -e /usr/lib64/qt6/qml/M3Shapes/qmldir ]]; then
    warn "$T_WARN_M3"
fi

printf '\n'
bold "$T_PLAN"
printf '\n\n'
printf '  1. %s: %s\n' "$T_CURRENT_DM" "$CURRENT_DM_LABEL"
printf '  2. %s: %s\n' "$T_TARGET_USER" "$TARGET_USER"
printf '  3. %s.\n' "$T_BACKUP_EXPLAIN"
printf '  4. %s.\n' "$T_DISABLE_EXPLAIN"
printf '  5. %s.\n' "$T_INSTALL_EXPLAIN"
printf '  6. %s.\n' "$T_CACHE_EXPLAIN"
if ((CONFIGURE_KEYRING)); then printf '  7. %s.\n' "$T_PAM_EXPLAIN"; fi
printf '  8. %s.\n' "$T_ENABLE_EXPLAIN"
printf '  9. %s.\n' "$T_RESTORE_EXPLAIN"
printf '\n'

if ((ASSUME_YES == 0)); then
    read -r -p "$T_CONFIRM: " confirmation
    if [[ "$confirmation" != "INSTALAR" && "$confirmation" != "INSTALL" ]]; then
        printf '%s\n' "$T_CANCEL"
        exit 0
    fi
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_BASE/$STAMP"
CURRENT_STEP="$T_BACKUP"
info "$CURRENT_STEP"
install -d -m 0700 "$BACKUP_DIR/files"
: > "$BACKUP_DIR/backed-up-paths.txt"
collect_backup
PREVIOUS_DM_ENABLED=""
PREVIOUS_DM_ACTIVE=""
if [[ -n "$CURRENT_DM_SERVICE" ]]; then
    PREVIOUS_DM_ENABLED="$(systemctl is-enabled "$CURRENT_DM_SERVICE" 2>/dev/null || true)"
    PREVIOUS_DM_ACTIVE="$(systemctl is-active "$CURRENT_DM_SERVICE" 2>/dev/null || true)"
fi
{
    printf 'version=%q\n' "$VERSION"
    printf 'installed_at=%q\n' "$(date --iso-8601=seconds)"
    printf 'target_user=%q\n' "$TARGET_USER"
    printf 'previous_dm_service=%q\n' "$CURRENT_DM_SERVICE"
    printf 'previous_dm_label=%q\n' "$CURRENT_DM_LABEL"
    printf 'previous_dm_enabled=%q\n' "$PREVIOUS_DM_ENABLED"
    printf 'previous_dm_active=%q\n' "$PREVIOUS_DM_ACTIVE"
} > "$BACKUP_DIR/metadata.env"
chmod 0600 "$BACKUP_DIR/metadata.env"

CURRENT_STEP="$T_INSTALL_FILES"
info "$CURRENT_STEP"
if ! getent passwd greeter >/dev/null 2>&1; then
    useradd --system --home-dir /var/lib/greeter --create-home --shell /usr/bin/nologin greeter
fi
install_project

CURRENT_STEP="$T_PAM"
info "$CURRENT_STEP"
configure_pam_keyring

CURRENT_STEP="$T_SYNC"
info "$CURRENT_STEP"
install -d -m 0755 "$BACKUP_BASE" "$CACHE_DIR" "$RUNTIME_DIR"
CAELESTIA_GREETER_USER="$TARGET_USER" /usr/local/bin/caelestia-greeter-profile-sync

CURRENT_STEP="$T_SWITCH"
info "$CURRENT_STEP"
systemctl daemon-reload
if [[ -n "$CURRENT_DM_SERVICE" && "$CURRENT_DM_SERVICE" != "greetd.service" ]]; then
    systemctl disable "$CURRENT_DM_SERVICE" >/dev/null 2>&1 || warn "Could not disable $CURRENT_DM_SERVICE automatically."
fi
systemctl enable -f greetd.service

cat > /var/lib/caelestia-greeter-install.env <<STATE
CAELESTIA_GREETER_VERSION='$VERSION'
CAELESTIA_GREETER_BACKUP='$BACKUP_DIR'
CAELESTIA_GREETER_PREVIOUS_DM='$CURRENT_DM_SERVICE'
CAELESTIA_GREETER_TARGET_USER='$TARGET_USER'
STATE
chmod 0600 /var/lib/caelestia-greeter-install.env

printf '\n'
bold "$T_DONE"
printf '\n\n'
printf '%s: %s\n' "$T_BACKUP_PATH" "$BACKUP_DIR"
printf '%s:\n  sudo caelestia-greeter-restore %q\n' "$T_RESTORE_CMD" "$BACKUP_DIR"
printf '\n%s.\n' "$T_REBOOT"
