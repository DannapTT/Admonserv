#!/bin/bash

echo "Listado de interfaces de red disponibles:" 
ip -br a
read -p "Escribe el nombre de la interfaz a modificar: " interfaz

estado=$(ip -br link show "$interfaz" | awk '{print $2}')
nuevo_estado="up"
[[ "$estado" == "UP" ]] && nuevo_estado="down"

sudo ip link set "$interfaz" "$nuevo_estado"
echo "Estado de la interfaz $interfaz cambiado a: $nuevo_estado"

read -p "Quieres conectarte por WiFi (1) o por cable (2)? " eleccion
if [[ "$eleccion" == "1" ]]; then
    echo "Escaneando redes WiFi disponibles..."
    sudo iwlist "$interfaz" scan | grep 'ESSID'
    read -p "Introduce el nombre de la red WiFi: " nombre
    read -sp "Introduce la contraseña de la red WiFi: " contrasena
    echo
    wpa_passphrase "$nombre" "$contrasena" | sudo tee /etc/wpa_supplicant.conf > /dev/null
    sudo wpa_supplicant -B -i "$interfaz" -c /etc/wpa_supplicant.conf
    echo "Se ha establecido la conexión con la red $nombre."
fi

read -p "Deseas configurar la red con DHCP (1) o con una IP fija (2)? " eleccion2
if [[ "$eleccion2" == "1" ]]; then
    sudo dhclient "$interfaz"
    echo "La configuración de red mediante DHCP se ha completado."
else
    read -p "Introduce la dirección IP: " direccion
    read -p "Introduce la máscara de red: " mascara
    read -p "Introduce la puerta de enlace: " puerta
    sudo ip addr add "$direccion/$mascara" dev "$interfaz"
    sudo ip route add default via "$puerta"
    echo "Se ha configurado la red con una IP fija."
fi
