# Activează Starship (promptul șmecher)
eval "$(starship init zsh)"

# Activează plugin-urile de Arch (dacă le-ai instalat la pasul anterior)
# Verificăm dacă fișierele există înainte să le încărcăm, ca să nu primim erori
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Istoric comenzi (opțional, dar util)
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt SHARE_HISTORY

# Alias-uri utile
alias ll='ls -alF'
alias update='sudo pacman -Syu'
alias ls='eza --icons --grid --header'

# --- Fix Keybindings pentru Alacritty/Zsh ---
# Ctrl + Sageata Dreapta (sari un cuvant inainte)
bindkey "^[[1;5C" forward-word
# Ctrl + Sageata Stanga (sari un cuvant inapoi)
bindkey "^[[1;5D" backward-word

# Backspace sterge tot cuvantul (Ctrl + Backspace)
bindkey '^H' backward-kill-word

# Home si End
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
# Ctrl + U sterge toata linia (indiferent de pozitia cursorului)
bindkey "^U" kill-whole-line
#ctrl + w sterge la stanga
#alt + d sterge la dreapta
#ctrl + l da clear la ecran
source /usr/share/nvm/init-nvm.sh

# bun completions
[ -s "/home/hiken/.bun/_bun" ] && source "/home/hiken/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


