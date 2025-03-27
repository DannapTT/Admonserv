#!/bin/bash

minimo=8
mayuscula=1
numero=1
especial=1

function validar_contrasena() {
    local contrasena="$1"
    local longitud=${#contrasena}

    [[ $longitud -lt $minimo ]] && echo "La contraseña debe tener al menos $minimo caracteres" && return 1
    [[ $mayuscula -eq 1 && ! "$contrasena" =~ [A-Z] ]] && echo "La contraseña debe contener al menos una letra mayúscula" && return 1
    [[ $numero -eq 1 && ! "$contrasena" =~ [0-9] ]] && echo "La contraseña debe contener al menos un número" && return 1
    [[ $especial -eq 1 && ! "$contrasena" =~ [^a-zA-Z0-9] ]] && echo "La contraseña debe contener al menos un carácter especial" && return 1
    return 0
}

echo "Ingrese el nombre de usuario: "
read usuario
echo "Ingrese el nombre completo del usuario: " 
read comentario
echo "Ingrese el directorio home [/home/$usuario]: "
read dir_hogar
echo "Ingrese el grupo del usuario: " 
read grupo

[[ -z "$dir_hogar" ]] && dir_hogar="/home/$usuario"

grep -q "^$grupo:" /etc/group || groupadd "$grupo"

while true; do
    read -s -p "Ingrese la contraseña: " contrasena
    echo 
    read -s -p "Confirme la contraseña: " contrasena_conf
    echo 
    
    if [[ "$contrasena" != "$contrasena_conf" ]]; then
        echo "Las contraseñas no coinciden, intente otra vez"
        continue
    fi
    if validar_contrasena "$contrasena"; then
        break
    fi
done

useradd -m -d "$dir_hogar" -c "$comentario" -g "$grupo" "$usuario"
sudo usermod --password $(openssl passwd -1 "$contrasena") "$usuario"

if [[ $? -eq 0 ]]; then
    echo "Usuario $usuario creado"
else
    echo "Hubo un error al crear el usuario"
fi
