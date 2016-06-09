#!/bin/bash
#menu
while : 
do
	clear
echo 		MENU
echo
echo
echo 1 IP y Hostname
echo 2 Crear grupo
echo 3 Crear un usuario
echo 4 Cambiar el password de un usuario
echo 5 Mostrar usuarios del sistema
echo 6 Mostrar grupos del sistema
echo 7 Detener y salir
echo
echo "Escribar el numero de la opcion elejida: ";read op;

case $op in 
  1) 
    echo
    echo "HOSTNAME: "; hostname
    echo
    echo " IP: "; hostname -I
    sleep 5
    ;;
  2) 
    echo -n "INGRESE NOMBRE DEL NUEVO GRUPO: "; read grupo
    encontrar=`cat /etc/group | grep "$grupo"`
    if [ $encontrar ]
    then 
      echo "EL GRUPO "$grupo" YA EXISTE"
    else
      groupadd $grupo
      echo "EL GRUPO "$grupo " SE CREO EXITOSAMENTE"
    fi 
    sleep 5
    ;;
  3) 
    echo -n "INGRESE NOMBRE DEL NUEVO USUARIO: "; read usuario
    encontrar=`cat /etc/passwd | grep "$usuario"`
    if [ $encontrar ]
    then
      echo "EL USUARIO "$usuario" YA EXISTE"
    else
      useradd $usuario
      echo "EL USUARIO "$usuario " SE CREO EXITOSAMENTE"
    fi 
    sleep 5
    ;;
  4) 
    echo -n "USUARIO AL QUE SE LE CAMBIARA PASSWORD:  "; read user 
    encontrar=`cat /etc/passwd | grep "$user"`
    if [ $encontrar ]
    then
      echo USUARIO EXIXTENTE
      passwd $user 
      echo "SE CAMBIO LA CONTRASEÑA  AL USUARIO " $usuario" EXITOSAMENTE"
    else
      echo "EL USUARIO "$user" NO EXISTE"
    fi
    sleep 5
    ;;
  5) 
    echo "USUARIOS EXIXTENTES"
    cut -d : -f 1 /etc/passwd | more -18 
    sleep 5
    ;;
  6) 
    echo "GRUPOS EXIXTENTES"
    #groups;;
    cut -d : -f 1 /etc/group   | more -18
    sleep 5
    ;;
  7) 
    echo HA FINALIZADO SCRIPT
    sleep 5
    clear
    exit 0
    ;;
  *) 
    echo OPCION INVALIDA
    sleep 5
esac
done
