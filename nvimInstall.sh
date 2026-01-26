#!/bin/bash

# Culori pentru terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Pornesc instalarea completă pentru Neovim (v0.12-dev + Dependințe)...${NC}"

# 1. Ne asigurăm că avem un AUR helper (yay)
if ! command -v yay &> /dev/null; then
    echo -e "${BLUE}📦 Instalez yay (AUR helper)...${NC}"
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    cd -
fi

# 2. Instalare Neovim Nightly/Git (versiunea pe care o ai acum)
echo -e "${BLUE}🔧 Instalez Neovim (versiunea de dezvoltare)...${NC}"
# neovim-git te asigură că ai mereu ultimul commit de pe master
yay -S --needed --noconfirm neovim-git

# 3. Instalare dependințe de sistem (tot ce a cerut checkhealth)
echo -e "${BLUE}📚 Instalez dependințele de sistem...${NC}"
SYSTEM_PKGS=(
    ripgrep fd fzf unzip wget curl git wl-clipboard
    lua51 luarocks python-pip python-pynvim
    nodejs npm ruby php php-composer
    tree-sitter tree-sitter-cli imagemagick ghostscript
    rustup gcc cmake
)
sudo pacman -S --needed --noconfirm "${SYSTEM_PKGS[@]}"

# 4. Configurare medii de limbaj
echo -e "${BLUE}🛠️ Configurez Python, Ruby și Rust...${NC}"
rustup default stable 2>/dev/null
sudo npm install -g neovim eslint_d @fsouza/prettierd prettier
sudo gem install neovim 2>/dev/null

# 5. Fix pentru plugin-uri specifice
echo -e "${BLUE}🧪 Instalez jsregexp pentru Luasnip...${NC}"
sudo luarocks install jsregexp 2>/dev/null

# 6. Magia finală: Instalarea plugin-urilor fără să deschizi editorul
echo -e "${BLUE}💤 Sync la plugin-uri (Lazy.nvim)...${NC}"
# Această comandă pornește nvim, instalează tot prin Lazy și se închide singură
nvim --headless "+Lazy! sync" +qa

echo -e "${GREEN}✅ Totul este gata! Neovim-ul tău este acum identic cu cel de pe PC-ul vechi.${NC}"

