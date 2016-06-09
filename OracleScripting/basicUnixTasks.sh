
_showIPAndHost() {
    clear
    echo
    echo "Dirección IP y hostname"

    echo -n " * El nombre del host es: "
    hostname
    echo -n " * La dirección IP es: "
    hostname -I

    echo
    read -p "Pulse enter para continuar" any
}

_createGroup() {
    clear
    echo
    read -p "Ingrese el nombre para el grupo: " groupname

    sudo groupadd -f ${groupname}
    echo "El grupo '${groupname}' ha sido creado exitosamente"

    echo
    read -p "Pulse enter para continuar" any
}







trap '' 2 
trap '' SIGTSTP
while :
do
    clear
    echo
    echo "Elija una tarea a realizar"
    echo
    echo "1. Mostrar IP y nombre de host"
    echo "2. Crear un grupo"
    echo "3. Crear un usuario"
    echo "4. Cambiar el password de un usuario"
    echo "5. Mostrar usuarios creados"
    echo "6. Mostrar grupos creados"
    echo "7. Salir"

    read -p "Escriba el número de la acción que desea ejecutar: " selection

    case $selection in
        1)
            _showIPAndHost
            ;;
        2)
            _createGroup
            ;;
        3)
            ;;
        7)
            clear
            exit
            ;;
        *)
            echo "Invalid option"
    esac
done
trap 2
trap '' - SIGTSTP
