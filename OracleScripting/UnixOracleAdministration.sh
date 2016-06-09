#!/bin/bash
trap 'echo "INVALID OPTION SELECTED"' 2 20
_menuprincipal(){
	clear
	echo "Oracle Opciones de adminsitración"
	echo
	echo "1 Arranque de oracle"
	echo "2 Detener oracle"
	echo "3 Salir"
	echo	
	read -p "Introduzca la opción elejida " op
}

_menualta(){
	clear
	echo
	echo " Oracle startup options"
	echo "1 ALTA DE sql"
	echo "2 ALTA DE LISTENER"
	echo "3 ALTA DE E.MANAGER"
	echo "4 ALTA DE SQLPLUS. LISTENER, E.MANAGER, PROCESOS Y PUERTOS"
	echo "5 SALIR"
	echo
	read -p "SELECCIONE UN OPCION " op2
}

_menubaja(){
	clear
	echo
	echo "Oracle stop options"
	echo "1 BAJA DE SQLPLUS"
	echo "2 BAJA DE LISTENER"
	echo "3 BAJA DE E.MANAGER"
	echo "4 BAJA DE SQLPLUS. LISTENER, E.MANAGER, PROCESOS Y PUERTOS"
	echo "5 SALIR"
	echo
	read -p "SELECCIONE UN OPCION " opb
}

_altaSQLvalidate(){
# CHECK STATUS FOR SQLPLUS
ORATAB=/etc/oratab
db=`egrep -i ":Y|:N" $ORATAB | cut -d":" -f1 | grep -v "\#" | grep -v "\*"`
pslist="`ps -ef | grep pmon`"
for i in $db ; do
echo  "$pslist" | grep  "ora_pmon_$i"  > /dev/null
if (( $? )); 
then
echo "Oracle Instance - $i:       Down"
sqlplus /nolog <<EOF
connect /as sysdba 
startup
quit
EOF
else
echo "Oracle Instance - $i:       Up"
fi
done 
}


_bajaSQLvalidate(){
# CHECK STATUS FOR SQLPLUS
ORATAB=/etc/oratab
db=`egrep -i ":Y|:N" $ORATAB | cut -d":" -f1 | grep -v "\#" | grep -v "\*"`
pslist="`ps -ef | grep pmon`"
for i in $db ; do
echo  "$pslist" | grep  "ora_pmon_$i"  > /dev/null
if (( $? )); 
then
echo "Oracle Instance - $i:       Down"
else
echo "Oracle Instance - $i:       Up"
sqlplus /nolog <<EOF
connect /as sysdba 
shut immediate
quit
EOF
fi
done 
}

_showSQLPLUS(){
# CHECK STATUS FOR SQLPLUS
ORATAB=/etc/oratab
db=`egrep -i ":Y|:N" $ORATAB | cut -d":" -f1 | grep -v "\#" | grep -v "\*"`
pslist="`ps -ef | grep pmon`"
for i in $db ; do
echo  "$pslist" | grep  "ora_pmon_$i"  > /dev/null
if (( $? )); then
echo "Oracle Instance - $i:       Down"
else
echo "Oracle Instance - $i:       Up"
fi
done  
}

_showlistener(){

  ##
    ## ~$ ps -ef                  // List all server processes
    ## ~$ grep 'tnslsnr LISTENER' // Filter only processes that contains 'tnslsnr LISTENER'
    ## ~$ grep -v grep            // Remove the grep self process
    ## ~$ wc -l                   // Count the number of lines in results (Process count)
orLsnrCmd=`ps -ef | grep 'tnslsnr LISTENER' | grep -v grep | wc -l`
orLsnrPsNum=`expr $orLsnrCmd`
if [ $orLsnrPsNum -lt 1 ]
then
isLsnrUp=false
echo "LISTENER DETENIDO"
sleep 3
else
isLsnrUp=true
echo "LISTENER INICIADO"
sleep 3
fi
}

_altalistener(){ 
_showlistener
clear
if [ $isLsnrUp = true ]
then
echo " listener activo"
sleep 3
else
lsnrctl start
clear
echo " LISTENER INICIADO"
fi
}
_bajalistener(){ 
_showlistener
clear
if [ $isLsnrUp = true ]
then
lsnrctl stop
clear
echo "LISTENER DETENIDO"
sleep 3
else
echo " LISTENER NO INICIADO"
sleep 3
fi
}

_altaemanager(){ 
emctl start dbconsole 
}

_bajaemanager(){ 
emctl stop dbconsole 
}

_procesos(){ 
# CHECK STATUS FOR SQLPLUS
ORATAB=/etc/oratab
db=`egrep -i ":Y|:N" $ORATAB | cut -d":" -f1 | grep -v "\#" | grep -v "\*"`
pslist="`ps -ef | grep pmon`"
for i in $db ; do
  echo  "$pslist" | grep  "ora_pmon_$i"  > /dev/null
  if (( $? )); then
        echo "NO eXISTEN PROCESOS"
  else
        echo "PROCESSOS"
ps -ef | grep -E 'pmon|smon|dbwr|lgwr|arch' | grep -v grep
  fi
done 
 }

_puertos(){
	echo "List of ports"
	  netstat -l | grep -E '1521|1526|1630|1830'
sleep 5
}

_showEMANAGER(){ 
emctl status oms 
}

_menualtaORACLE(){
_menualta
case $op2 in
1) echo
#ALTA DE SQLPLUS
_altaSQLvalidate
clear 
echo "Oracle iniciado correctamente"
sleep 3
;;
2) echo
#ALTA DE LISTENER
_altalistener
clear 
	echo "Iniciando listener"
	sleep 3
;;
	3) echo
	#ALTA DE ENTERPRICE MANAGER
	_altaemanager
	;;
	4) echo
	# ALTA DESQLPLUS. LISTENER, E.MANAGER, PROCESOS Y PUERTOS
	_showSQLPLUS
sleep 3
	_showlistener
sleep 3	
#_showEMANAGER
	_procesos
sleep 3
	_puertos
sleep 5	
;;
	5) echo
	#SALIR
	;;
	*) echo OPCION INVALIDA
	esac
}

_menubajaORACLE(){
_menubaja
case $opb in
1) echo
#BAJA DE SQLPLUS
_bajaSQLvalidate
clear 
echo "BASE DE DATOS DETENIDA CORRETAMENTE"
sleep 3
;;
	2) echo
	#BAJA DE LISTENER
	_bajalistener
clear 
	echo "BAJA DE LISTENER"
	sleep 3
	;;
	3) echo
	#BAJA DE ENTERPRICE MANAGER
	_bajaemanager
	;;
	4) echo 
	# ALTA DESQLPLUS. LISTENER, E.MANAGER, PROCESOS Y PUERTOS
	_showSQLPLUS
sleep 3
	_showlistener
sleep 3	
#_showEMANAGER
	_procesos
sleep 3	
_puertos
sleep 3
	;;
	5) echo 
	#SALIR
	 echo "Bye"
	;;
	*) echo OPCION INVALIDA
	esac	
}

#MENU PRINCIPAL ADMINISTRACION DE ORACLE
_menuAdministracionOracle(){
_menuprincipal
case $op in 
1) echo
_menualtaORACLE
;;
2) echo
_menubajaORACLE
;;
3) echo
;;
*) echo OPCION INVALIDA
esac
}

_cambiapass(){
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
}
_gruposExistentes(){
	echo "GRUPOS EXIXTENTES"
#groups;;
cut -d : -f 1 /etc/group   | more -18
sleep 5
}
_addUser(){
	echo -n "INGRESE NOMBRE DEL NUEVO USUARIO: "; read usuario
encontrar=`cat /etc/passwd | grep "$usuario"`
if [ $encontrar ]
then
echo "EL USUARIO "$usuario" YA EXISTE"
else
sudo useradd $usuario
echo "EL USUARIO "$usuario " SE CREO EXITOSAMENTE"
fi 
sleep 5
}
_addGroup(){
	echo -n "INGRESE NOMBRE DEL NUEVO GRUPO: "; read grupo
encontrar=`cat /etc/group | grep "$grupo"`
if [ $encontrar ]
then
echo "EL GRUPO "$grupo" YA EXISTE"
else
sudo groupadd $grupo
echo "EL GRUPO "$grupo " SE CREO EXITOSAMENTE"
fi 
sleep 5
}
_ipHost(){
	echo "HOSTNAME: "; hostname
echo
echo " IP: "; hostname -I
sleep 5
}
_usuariosExixtentes(){
	echo "USUARIOS EXIXTENTES"
cut -d : -f 1 /etc/passwd | more -18 
sleep 5
}
_menuAdministracionUnix(){
	clear
echo 		MENU
echo
echo
echo 1.-mostrar ip y nombre del host
echo 2.-crear un grupo
echo 3.-crear un usuario
echo 4.-cammbiar password
echo 5.-mostrar usuarios creados
echo 6.-mostrar grupos creados
echo 7.-salir
echo
echo "SELECCIONE UN OPCION";read op;
case $op in 
1) echo
_ipHost
;;
2) echo
_addGroup
;;
3) echo 
_addUser
;;
4) 
if [ "$(id -u)" != "0" ]; then
   echo "SOLO USUARIO ROOT PUEDE CAMBIAR PASSWORD" 1>&2
else
_cambiapass
fi
sleep 5
;;
5) echo
_usuariosExixtentes
;;
6) echo
_gruposExistentes
;;
7) echo
;;
*) echo OPCION INVALIDA
sleep 3
esac
}

while : 
do
		clear
echo 		MENU
echo
echo
echo 1.-Administracion de oracle
echo 2.-Administracion de Unix
echo 3.-salir
echo
echo "SELECCIONE UN OPCION";read op;
case $op in 
1) echo
_menuAdministracionOracle
;;
2) echo
_menuAdministracionUnix
;;
3) echo HA FINALIZADO SCRIPT
sleep 3
clear
exit 0
;;
*) echo OPCION INVALIDA
sleep 3
esac
done
