#!/bin/sh
# Install script for cog CLI
# Usage: curl -fsSL https://raw.githubusercontent.com/mechanical-advantage-ai/cog/main/install.sh | sh
set -e

REPO="mechanical-advantage-ai/cog"
BINARY="cog"
INSTALL_DIR="$HOME/.cog/bin"

detect_os() {
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    case "$os" in
        darwin)  echo "darwin" ;;
        linux)   echo "linux" ;;
        mingw*|msys*|cygwin*) echo "windows" ;;
        *)
            echo "Error: unsupported operating system: $os" >&2
            exit 1
            ;;
    esac
}

detect_arch() {
    arch=$(uname -m)
    case "$arch" in
        x86_64|amd64)    echo "amd64" ;;
        aarch64|arm64)   echo "arm64" ;;
        *)
            echo "Error: unsupported architecture: $arch" >&2
            exit 1
            ;;
    esac
}

get_latest_version() {
    # Use the releases/latest redirect to extract the version tag.
    # This avoids the GitHub API rate limit (60 req/hr unauthenticated)
    # that the /repos/{owner}/{repo}/releases/latest endpoint is subject to.
    redirect_url=$(curl -fsSI "https://github.com/${REPO}/releases/latest" 2>/dev/null |
        grep -i '^location:' |
        tail -n 1 |
        sed 's/location: *//i' |
        tr -d '\r')

    if [ -n "$redirect_url" ]; then
        version=$(printf '%s\n' "$redirect_url" | grep '/tag/' | head -n 1 | sed 's|.*/tag/||')
        if [ -n "$version" ]; then
            echo "$version"
            return
        fi
    fi

    # Fallback to the GitHub API if the redirect method fails.
    if ! response=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest"); then
        echo "Error: failed to fetch the latest release from GitHub" >&2
        echo "This may be due to GitHub API rate limiting. Try again later or set COG_VERSION=vX.Y.Z" >&2
        exit 1
    fi

    version=$(printf '%s\n' "$response" |
        grep '"tag_name"' |
        sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')

    if [ -z "$version" ]; then
        echo "Error: failed to determine the latest release version" >&2
        exit 1
    fi

    echo "$version"
}

add_to_path() {
    path_entry='export PATH="$HOME/.cog/bin:$PATH"'

    # Detect shell and rc file
    if [ -n "$SHELL" ]; then
        shell_name=$(basename "$SHELL")
    else
        shell_name=""
    fi

    case "$shell_name" in
        zsh)  rc_file="$HOME/.zshrc" ;;
        bash)
            if [ -f "$HOME/.bashrc" ]; then
                rc_file="$HOME/.bashrc"
            else
                rc_file="$HOME/.bash_profile"
            fi
            ;;
        fish)
            # Fish uses a different syntax
            fish_path_cmd="fish_add_path $HOME/.cog/bin"
            fish_config="$HOME/.config/fish/config.fish"
            if [ -f "$fish_config" ] && grep -qF ".cog/bin" "$fish_config" 2>/dev/null; then
                return
            fi
            mkdir -p "$(dirname "$fish_config")"
            echo "$fish_path_cmd" >> "$fish_config"
            echo "Added $INSTALL_DIR to PATH in $fish_config"
            return
            ;;
        *)    rc_file="$HOME/.profile" ;;
    esac

    # Check if already in the rc file
    if [ -f "$rc_file" ] && grep -qF ".cog/bin" "$rc_file" 2>/dev/null; then
        return
    fi

    echo "" >> "$rc_file"
    echo "# Added by cog CLI installer" >> "$rc_file"
    echo "$path_entry" >> "$rc_file"
    echo "Added $INSTALL_DIR to PATH in $rc_file"
}

main() {
    os=$(detect_os)
    arch=$(detect_arch)

    echo "Detected: ${os}/${arch}"

    # Get version (allow override via COG_VERSION env var)
    version="${COG_VERSION:-$(get_latest_version)}"
    version_num="${version#v}"

    echo "Installing cog ${version}..."

    # Determine archive extension
    ext="tar.gz"
    if [ "$os" = "windows" ]; then
        ext="zip"
    fi

    # Construct download URL
    filename="${BINARY}_${version_num}_${os}_${arch}.${ext}"
    url="https://github.com/${REPO}/releases/download/${version}/${filename}"

    # Create temp directory with cleanup trap
    tmp_dir=$(mktemp -d)
    trap 'rm -rf "$tmp_dir"' EXIT

    echo "Downloading ${url}..."
    curl -fsSL -o "${tmp_dir}/${filename}" "$url"

    # Extract
    if [ "$ext" = "zip" ]; then
        unzip -q "${tmp_dir}/${filename}" -d "${tmp_dir}"
    else
        tar -xzf "${tmp_dir}/${filename}" -C "${tmp_dir}"
    fi

    # Install binary
    mkdir -p "$INSTALL_DIR"
    cp "${tmp_dir}/${BINARY}" "${INSTALL_DIR}/${BINARY}"
    chmod +x "${INSTALL_DIR}/${BINARY}"

    # Add to PATH if needed
    case ":$PATH:" in
        *":$INSTALL_DIR:"*) ;;
        *) add_to_path ;;
    esac

    echo ""
    echo "cog ${version} installed successfully to ${INSTALL_DIR}/${BINARY}"
    echo ""
    if ! command -v cog >/dev/null 2>&1; then
        echo "Restart your shell or run:"
        echo "  export PATH=\"\$HOME/.cog/bin:\$PATH\""
        echo ""
    fi
    echo "Run 'cog --help' to get started."
}

main
