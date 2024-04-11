#!/bin/bash

welcome(){

echo -e "
 ######                            #     #          
 #     # #####  # #    #  ####     ##   ## #   #    
 #     # #    # # ##   # #    #    # # # #  # #     
 ######  #    # # # #  # #         #  #  #   #      
 #     # #####  # #  # # #  ###    #     #   #      
 #     # #   #  # #   ## #    #    #     #   #      
 ######  #    # # #    #  ####     #     #   #      
                                                    
  #####                                             
 #     # ###### ##### ##### # #    #  ####   ####   
 #       #        #     #   # ##   # #    # #       
  #####  #####    #     #   # # #  # #       ####   
       # #        #     #   # #  # # #  ###      #  
 #     # #        #     #   # #   ## #    # #    #  
  #####  ######   #     #   # #    #  ####   ####   

BMS Version 0.1   
" 
}

print_loading_bar() {
    local bar_length=50
    local total_duration=$1
    local update_interval=$(awk "BEGIN { print $total_duration / $bar_length }")
    
    for ((i = 0; i <= bar_length; i++)); do
        echo -ne "\r["
        for ((j = 1; j <= bar_length; j++)); do
            if [ "$j" -le "$i" ]; then
                echo -ne "="
            else
                echo -ne "-"
            fi
        done
        echo -ne "] $((i * 100 / bar_length))%"
        sleep $update_interval
    done

    echo -ne "\n"
}

replace_gitconfig(){
    gitconfig_path=~/.gitconfig
    branch_name=main
    new_username=""
    new_email=""

    if [ -f "$gitconfig_path" ]; then
        echo "Se ha encontrado un archivo de configuración en $gitconfig_path"
    else
        echo "No se encontró un archivo de configuración en $gitconfig_path"
        touch ~/.gitconfig
        echo "Se ha creado un nuevo archivo de configuración en $gitconfig_path"
    fi

    echo "Estableciendo default branch como $branch_name"

    git config --global init.defaultBranch $branch_name

    existing_username=$(git config --global user.name)
    existing_email=$(git config --global user.email)

    if [ -n "$existing_username" ] && [ -n "$existing_email" ]; then
        echo -e "\n"
        echo "Configuraciones existentes:"
        echo "Nombre de usuario: $existing_username"
        echo "Correo electrónico: $existing_email"
        echo -e "\n"
    fi
    read -p "¿Está seguro de que desea cambiar las credenciales? (y/n): " answer

    if [[ $answer =~ ^[Yy]$ ]]; then

        read -p "¿Quieres usar los datos por defecto? (y/n): " answer

        if [[ $answer =~ ^[Yy]$ ]]; then
            new_username=""
            new_email=""
        else
            read -p "Ingrese su nombre de usuario para Git: " new_username
                git config --global user.name "$new_username"
            read -p "Ingrese su correo electrónico para Git: " new_email
                git config --global user.email $new_email
        fi
        git config --global user.name "$new_username"
        git config --global user.email $new_email
        git config --global core.editor "code --wait"
        echo -e "\n"
        echo "Credenciales actualizadas con éxito."
        echo -e "\n"
    else
        echo -e "\n"    
        echo "Operación cancelada. No se cambiaron credenciales."
        echo -e "\n"
    fi
}

vs_clear() {
    code --list-extensions

    echo -e "\n"
    read -p "¿Está seguro de que desea desinstalar todas las extensiones de VSCode? (y/n): " answer

    if [[ $answer =~ ^[Yy]$ ]]; then
        if [ -z "$(code --list-extensions)" ]; then
            echo "No se encontraron extensiones instaladas."
        else
            echo "Se encontraron extensiones instaladas. Desinstalando..."
            echo -e "\n"
            code --list-extensions | xargs -L 1 code --uninstall-extension
        fi
    else
        echo "Operación cancelada. No se desinstalaron extensiones."
    fi
}

ask_for_extension_profile() {
    echo -e "\n"
    echo "Seleccione un perfil de extensiones:"
    echo "0. Omitir"
    echo "1. Perfil Python"
    echo "2. Perfil Web"
    echo -e "\n"
    read -p "Ingrese el número del perfil deseado: " profile_choice

    extensions=()

    case $profile_choice in
        1)
            echo -e "\n"
            echo "Cargando extensiones del Perfil Python..."
            extensions=(
                "mhutchie.git-graph"
                "ms-python.python"
                "formulahendry.code-runner"
                "vivaxy.vscode-conventional-commits"
            )
            ;;
        2)
            echo -e "\n"
            echo "Cargando extensiones del Perfil Web..."
            extensions=(
                "mhutchie.git-graph"
                "ms-vsliveshare.vsliveshare"
                "pranaygp.vscode-css-peek"
                "rangav.vscode-thunder-client"
                "ritwickdey.LiveServer"
                "vivaxy.vscode-conventional-commits"
            )
            ;;
        0)
        
            echo -e "\n"
            echo "Omitiendo la instalación de extensiones."
            return
            ;;
        *)
            echo -e "\n"
            echo "Opción no válida. Finalizando el programa."
            exit 1
            ;;
    esac

    for extension in "${extensions[@]}"; do
        code --install-extension "$extension" 
    done
}

welcome
print_loading_bar 1/2
replace_gitconfig
vs_clear
ask_for_extension_profile