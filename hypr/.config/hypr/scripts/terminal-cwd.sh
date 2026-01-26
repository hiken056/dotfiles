#!/bin/bash

# Aflam informatii despre fereastra activa
ACTIVE=$(hyprctl activewindow -j)
# Luam numele clasei. 
# Nota: La Ghostty clasa este de obicei "com.mitchellh.ghostty"
CLASS=$(echo "$ACTIVE" | jq -r .class)

# Verificam daca clasa contine cuvantul "ghostty" (pentru a fi siguri)
if [[ "$CLASS" == *"ghostty"* ]]; then
    # Luam PID-ul ferestrei active
    PID=$(echo "$ACTIVE" | jq .pid)
    
    # Cautam procesul copil (Shell-ul)
    # Ghostty spawneaza shell-ul ca un copil direct al procesului UI
    SHELL_PID=$(pgrep -P $PID | tail -n 1)

    if [ -n "$SHELL_PID" ]; then
        # Citim folderul curent al acelui shell
        DIR=$(readlink /proc/$SHELL_PID/cwd)
        
        # Deschidem Ghostty in acel director
        ghostty --working-directory="$DIR"
    else
        # Fallback: deschidem normal in Home daca nu gasim PID-ul shell-ului
        ghostty
    fi
else
    # Daca fereastra activa nu e Ghostty, deschidem o instanta noua in Home
    ghostty
fi
