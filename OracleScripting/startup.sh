#!/bin/bash

_showStatus() {
    echo
    echo "Database status:"
    orPsString=`ps -ef|grep ${ORACLE_SID}|grep pmon|wc -l`;
    orPsNum=`expr $orPsString`
    sqlReturnCode=$?
    if [ $orPsNum -lt 1 ]
    then
        echo "Database instance is not running"
    else
        echo "Database instance is running"
    fi

    read -p "Press enter to continue " any

    echo
    echo "Listener status:"
    lsnrctl status
    read -p "Press enter to continue " any

    echo 
    echo "Enterprise manager status"
    emctl status
    read -p "Press enter to continue " any

    echo
    echo "Background processes"
    ps -ef | grep pman | more
    read -p "Press enter to continue" any

    echo
    echo "Oracle ports"
    netstat -na | more
}

_startupOptions() {
    clear
    echo "Oracle Startup options"
    echo

    echo "1. Oracle listener startup"
    echo "2. Oracle enterprise manager startup"
    echo "3. Database startup"
    echo "4. Show DBStartup, Listener status, Enterprise manager status, Background processes and Ports"
    echo "5. Go Back"
    echo 
    read -p "Type your option number: " selection;

    case $selection in
        1)
            clear
            lsnrctl start
            echo "Listener startup successful"
            ;;
        2)
            clear
            emctl start dbconsole
            echo "EM Startup successful"
            ;;
        3)
            clear
            sqlplus <<EOF
                CONNECT / AS SYSDBA
                STARTUP
                QUIT
EOF
            ;;
        4)
            clear
            _showStatus
            ;;
        *)
            echo "Please type a valid option"
    esac
}

_stopOptions() {
    clear
    echo "Oracle Stop/Down options"
    echo

    echo "1. Oracle listener service stop"
    echo "2. Oracle enterprise manager service stop"
    echo "3. Database shutdown"
    echo "4. Database shutdown immediate"
    echo "5. Show DB state, Listener status, Enterprise manager status, Background processes and Ports"
    echo "6. Go back"
    echo 
    read -p "Type your option number: " selection;

    case $selection in
        1)
            clear
            lsnrctl stop
            echo "Listener stop successful"
            ;;
        2)
            clear
            emctl stop dbconsole
            echo "EM stop successful"
            ;;
        3)
            clear
            sqlplus <<EOF
                CONNECT / AS SYSDBA
                SHUTDOWN
                QUIT
EOF
            ;;
        4)
            clear
            sqlplus <<EOF
                CONNECT / AS SYSDBA
                SHUTDOWN IMMEDIATE
                QUIT
EOF
            ;;
        5)
            clear
            _showStatus
            ;;
        *)
            echo "Please type a valid option"
    esac
}

##
## MAIN MENU
while :
do
    clear
    echo "Oracle administration options"
    echo
    echo "1. Oracle Services and instance startup"
    echo "2. Oracle Services and instance stop/down"
    echo "3. Exit"
    echo
    read -p "Type your option number: " selection1;

    case $selection1 in
        1) 
            _startupOptions
            ;;
        2)
            _stopOptions
            ;;
        3)
            exit
            ;;
        *) 
            echo "Invalid option"
    esac
done    

