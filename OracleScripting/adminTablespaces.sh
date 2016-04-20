
##-----------------------------------------------------------------------------
##-----------------------------------------------------------------------------
##
## Tablespace manipulation functions
##

_createTablespace() {
    _checkInstanceStatus

    if [ $isInstanceUp = true ]
    then
        clear
        echo
        read -p "Ingrese un nombre para el tablespace: " tbspName
        read -p "Ingrese el tamaño en MB para el tablespace: " tbspSize

        sqlplus <<EOF > logfile
            CONNECT / AS SYSDBA
            CREATE TABLESPACE ${tbspName} DATAFILE '/u01/app/oracle/oradata/orcl/${tbspName}.dbf' SIZE ${tbspSize}M;
EOF
        clear
        echo
        echo " * Tablespace '${tbspName}' creado exitosamente"
        read -p "Pulse enter para continuar" any
    fi
}

_createTemporaryTablespace() {
    _checkInstanceStatus

    if [ $isInstanceUp = true ]
    then
        clear
        echo
        read -p "Ingrese un nombre para el tablespace temporal: " tbspName
        read -p "Ingrese el tamaño en MB para el tablespace: " tbspSize

        sqlplus <<EOF > logfile
            CONNECT / AS SYSDBA
            CREATE TEMPORARY TABLESPACE ${tbspName} TEMPFILE '/u01/app/oracle/oradata/orcl/${tbspName}.dbf' SIZE ${tbspSize}M;
EOF
        clear
        echo
        echo " * Tablespace temporal '${tbspName}' creado exitosamente"
        read -p "Pulse enter para continuar" any
    fi
}

_deleteTablespace() {
    _checkInstanceStatus

    if [ $isInstanceUp = true ]
    then
        clear
        echo
        read -p "Ingrese el nombre del tablespace a eliminar: " tbspName

        sqlplus -S / AS SYSDBA <<EOF
            DROP TABLESPACE ${tbspName} INCLUDING CONTENTS AND DATAFILES;
            QUIT;
EOF

        clear
        echo " * EL tablespace ${tbspName} ha sido eliminado."
        read -p "Pulse enter para continuar" any
    fi
}

_viewTablespaces() {
    _checkInstanceStatus

    if [ $isInstanceUp = true ]
    then
        clear
        echo
        echo "Tablespaces de la instancia '${ORACLE_SID}': "
        
        sqlplus -S / AS SYSDBA <<EOF
            SET LINE 5000
            SELECT V\$TABLESPACE.NAME, ((SUM(V\$DATAFILE.BYTES) / 1024) / 1024) AS DATAFILES_SIZE_IN_MB FROM V\$TABLESPACE INNER JOIN V\$DATAFILE ON V\$DATAFILE.TS# = V\$TABLESPACE.TS# GROUP BY V\$TABLESPACE.NAME ORDER BY V\$TABLESPACE.NAME;
            QUIT;
EOF
        read -p "Pulse enter para continuar" any
    fi
}

_viewTemporaryTablespaces() {
    _checkInstanceStatus

    if [ $isInstanceUp = true ]
    then
        clear
        echo 
        echo "Tablespaces temporales de la instancia '${ORACLE_SID}': "

        sqlplus -S / AS SYSDBA <<EOF
            SET LINE 5000
            SELECT V\$TABLESPACE.NAME, ((SUM(DBA_TEMP_FILES.BYTES) / 1024) / 1024) AS TEMP_DATAFILE_SIZE_IN_MB FROM V\$TABLESPACE INNER JOIN DBA_TEMP_FILES ON DBA_TEMP_FILES.TABLESPACE_NAME = V\$TABLESPACE.NAME GROUP BY V\$TABLESPACE.NAME ORDER BY V\$TABLESPACE.NAME;
            QUIT;
EOF

        read -p "Pulse enter para continuar" any
    fi
}

_viewAllDatafiles() {
    _checkInstanceStatus

    if [ $isInstanceUp = true ]
    then
        clear
        echo
        echo "Datafiles de cada tablespace de la instancia ${ORACLE_SID}: "

        sqlplus -S / AS SYSDBA <<EOF
            SET LINE 90
            SET WRAP OFF
            SELECT TABLESPACE_NAME, FILE_NAME FROM DBA_DATA_FILES UNION SELECT TABLESPACE_NAME, FILE_NAME FROM DBA_TEMP_FILES ORDER BY TABLESPACE_NAME;
            QUIT;
EOF

        read -p "Pulse enter para continuar" any
    fi
}


##-----------------------------------------------------------------------------
##-----------------------------------------------------------------------------
##
## User manipulation functions
##

_createUserWithTablespace() {
   _checkInstanceStatus

  if [ $isInstanceUp = true ]
  then
      clear
      echo
      read -p "Ingrese el nombre del usuario: " username
      echo -n "Ingrese el password para el usuario: "
      read -s password
      echo
      read -p "Ingrese el default tablespace para el usuario: " tbsp

      #
      # Connect to sqlplus and create user
      sqlplus <<EOF > logfile
          CONNECT / AS SYSDBA
          CREATE USER ${username} IDENTIFIED BY ${password} DEFAULT TABLESPACE ${tbsp};
          QUIT;
EOF
      clear
      echo
      echo " * El usuario fue creado exitosamente"
      read -p "Pulse enter para continuar"
  fi
}

_deleteUser() {
   _checkInstanceStatus

    if [ $isInstanceUp = true ]
    then
        clear
        echo
        read -p "Ingrese el nombre del usuario a eliminar: " username

        sqlplus -S / AS SYSDBA <<EOF
            DROP USER ${username} CASCADE;
            QUIT;
EOF
        clear
        echo
        echo " * El usuario ${username} fue eliminado exitosamente"
        read -p "Pulse enter para continuar"
    fi 
}

_viewUsers() {
    _checkInstanceStatus

    if [ $isInstanceUp = true ]
    then
        clear
        echo
        echo "Los usuarios de la base de datos son: "
        
        sqlplus -S / AS SYSDBA <<EOF
            SET LINE 5000
            SELECT USERNAME, DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE FROM DBA_USERS ORDER BY USERNAME;
            QUIT;
EOF
        read -p "Pulse enter para continuar"
    fi
}


##-----------------------------------------------------------------------------
##
## Instance status functions
##

_checkInstanceStatus() {

    orInsPsStr=`ps -ef | grep smon | grep -v grep | grep ${ORACLE_SID} | wc -l`;
    orPsNum=`expr $orInsPsStr`

    if [ $orPsNum -lt 1 ]
    then
        echo " * Oracle instance ${ORACLE_SID} is not running."
        read -p "Type enter to continue" any
        isInstanceUp=false
    else
        isInstanceUp=true
    fi
}


##-----------------------------------------------------------------------------
##-----------------------------------------------------------------------------
##
## Main menu
##

while :
do
    clear
    echo "Oracle tablespaces administration menu"
    echo
    echo "1. Crear tablespace"
    echo "2. Crear tablespace temporal"
    echo "3. Crear usuario asignando tablespace"
    echo
    echo "4. Ver usuarios de la base de datos"
    echo "5. Ver tablespaces de la instancia"
    echo "6. Ver tablespaces temporales de la instancia"
    echo "7. Ver datafiles de cada tablespace"
    echo
    echo "8. Eliminar un tablespace"
    echo "9. Eliminar un usuario"
    echo "10. Exit"
    echo
    read -p "Type your option number: " selection1

    case $selection1 in
        1)
            _createTablespace
            ;;
        2)
            _createTemporaryTablespace
            ;;
        3)
            _createUserWithTablespace
            ;;
        4)
            _viewUsers
            ;;
        5)
            _viewTablespaces
            ;;
        6)
            _viewTemporaryTablespaces
            ;;
        7)
            _viewAllDatafiles
            ;;
        8)
            _deleteTablespace
            ;;
        9)
            _deleteUser
            ;;
        10)
            clear
            exit
            ;;
        *) 
            echo "Please type a valid option"
    esac
done
