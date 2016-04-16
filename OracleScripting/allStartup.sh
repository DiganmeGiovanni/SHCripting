#!/bin/bash


## ----------------------------------------------------------------------------
## ----------------------------------------------------------------------------
## 
## Oracle services status check functions
##

_showStatus() {
    echo
    echo "Checking if database instance '${ORACLE_SID}' is running:"
    _checkInstanceStatus
    read -p "Press enter to continue " any

    echo
    echo "Listener status:"
    _checkLsnrStatus
    read -p "Press enter to continue " any

    echo 
    echo "Enterprise manager status:"
    ## emctl status
    echo " * Enterprise manager is not running"
    read -p "Press enter to continue " any

    echo
    echo "Oracle active background processes:"
    _listBackgroundProcesses
    read -p "Press enter to continue" any

    echo
    echo "Oracle ports"
    _listOraclePorts
    read -p "Press enter to continue" any

}

_listBackgroundProcesses() {
    
    ##
    ## Oracle background processes:
    ## smon  - System monitor process
    ## pmon  - Process monitor process
    ## dbwr  - Database writer, writes to database datafiles
    ## lgwr  - Log writer, is responsible for writing the log buffers out to the redo logs
    ## arch  - Archive process writes filled redo logs to the archive logs locations
    ##
    ## Filter to search processes that belongs to oracle background
    ## in a similar way that functions to check statuses
    ##
    ps -ef | grep -E 'pmon|smon|dbwr|lgwr|arch' | grep -v grep
}

_listOraclePorts() {
    
    ##
    ## Oracle uses ports:
    ## 1521  - Oracle NET Listener
    ## 1526  - Edit listener and restart listener
    ## 1630  - Oracle Connection Manager
    ## 1830  - Oracle Connection Manager Admin
    ## 
    netstat -l | grep -E '1521|1526|1630|1830'
}

_checkInstanceStatus() {

    ##
    ## ~$ ps -ef             // List all the server processes
    ## ~$ grep smon          // Filter only processes that belongs to Oracle System background process (SMON)
    ## ~$ grep -v grep       // Remove the self grep process from be included in results
    ## ~$ grep ${ORACLE_SID} // (Optional) Filter only processed that belong to instance defined by ORACLE SID environment variable
    ## ~$ wc -l              // Counts the number of lines in result (Number of processes)
    orPsString=`ps -ef | grep smon | grep -v grep | grep ${ORACLE_SID} | wc -l`;
    orPsNum=`expr $orPsString`
    if [ $orPsNum -lt 1 ]
    then
        isInstanceUp=false
        echo " * Database instance is not running"
    else
        echo " * Database instance is running"
        isInstanceUp=true
    fi
}

_checkLsnrStatus() {
    
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
        echo " * Oracle listener is not running"
    else
        isLsnrUp=true
        echo " * Oracle listener is running"
    fi
}

## ----------------------------------------------------------------------------
## ----------------------------------------------------------------------------
## 
## Oracle services startup functions
##

_startInstance() {
    _checkInstanceStatus
    clear

    if [ $isInstanceUp = true ]
    then
        echo " * Instance is already running"
    else
        sqlplus /nolog <<EOF
            CONNECT / AS SYSDBA
            STARTUP
            QUIT
EOF
        clear
        echo " * Instance started successfully"
    fi

    read -p "Type enter to continue" any
}

_startLsnr() {
    _checkLsnrStatus
    clear

    if [ $isLsnrUp = true ]
    then
        echo " * Listener is already running"
    else
        lsnrctl start
        clear
        echo " * Listener started successfully"
    fi

    read -p "Type enter to continue" any
}


## ----------------------------------------------------------------------------
## ----------------------------------------------------------------------------
## 
## Oracle services stop functions
##

_stopInstance() {
    _checkInstanceStatus
    clear

    if [ $isInstanceUp = true ]
    then
        sqlplus /nolog <<EOF
            CONNECT / AS SYSDBA
            SHUTDOWN
            QUIT
EOF
        clear
        echo " * Instance shutdowns successfully"
    else
        echo " * Instance is already in shutdown status"
    fi

    read -p "Type enter to continue" any
}

_stopInstanceImmediate() {
    _checkInstanceStatus
    clear

    if [ $isInstanceUp = true ]
    then
        sqlplus /nolog <<EOF
            CONNECT / AS SYSDBA
            SHUTDOWN IMMEDIATE
            QUIT
EOF
        clear
        echo " * Instance shutdowns successfully"
    else
        echo " * Instance is already in shutdown status"
    fi

    read -p "Type enter to continue" any
}

_stopLsnr() {
    _checkLsnrStatus
    clear

    if [ $isLsnrUp = true ]
    then
        lsnrctl stop
        clear
        echo " * Listener stoped successfully"
    else
        echo " * Listener is currently not running"
    fi

    read -p "Type enter to continue" any
}


## ----------------------------------------------------------------------------
## ----------------------------------------------------------------------------
## 
## MAIN MENU
##

while :
do
    clear
    echo "Oracle administration options"
    echo
    echo "1. Start Oracle Instance, Listener and Enterprise Manager"
    echo "2. Stop Oracle Instance, Listener and Enterprise Manager"
    echo "3. Check Oracle services current status"
    echo "4. Exit"
    echo
    read -p "Type your option number: " selection1;

    case $selection1 in
        1) 
            _startInstance
            _startLsnr
            ## emctl start dbconsole
            ;;
        2)
            _stopLsnr
            _stopInstance
            ## emctl stop dbconsole
            ;;
        3)
            _showStatus
            ;;
        4) 
            clear 
            exit
            ;;
        *) 
            echo "Invalid option"
    esac
done    

