 #!/bin/bash

source id.txt

function _log(){
    trailbefore=$2
    start=""
    if [ -z $trailbefore ] || [ $trailbefore = true ]
        then
        start=" - "
    fi

    printf "$start$1"
}

function run_command (){
    COMMAND=$1
    # note in the original parameter count as new parameter
    QUERY="$2 $3"
    OUTPUT="--output text"
    local result=$(eval aws ec2 $COMMAND --instance-ids $INSTANCE_ID $QUERY $OUTPUT)
    echo "$result"
}

function getStatus(){
    CMD="describe-instances"
    EXTRA="--query \"Reservations[].Instances[].State[].Name\""
    result=$(run_command $CMD $EXTRA)
    echo $result
}

function _checkStatus(){
    status=$(getStatus)
    if [ $status = "pending" ] || [ $status = "stopping" ]
        then
        _log "Current status: $status"
        _log " Wating "
        while [ $status = "pending" ] || [ $status = "stopping" ]
            do
            sleep 5
            _log "." false
            status=$(getStatus)
        done
        _log "\n" false
    fi
}

function getIp(){
    CMD="describe-instances"
    EXTRA="--query \"Reservations[].Instances[].PublicIpAddress\""
    _checkStatus

    if [ $status = "running" ]
        then
        ip=$(run_command $CMD $EXTRA)
        if [ -z "$ip" ]
            then
            _log "Wating for ip "
            while [ -z "$ip" ]
                do
                _log "." false
                sleep 5
                ip=$(run_command $CMD $EXTRA)
            done
        fi
        ## return value
        _log "Found IP $ip of instance $INSTANCE_ID.\n"
        echo $ip >> ips.txt
    else
        _log "Instance $INSTANCE_ID is not runnning.\n"
    fi

}

function start {
    CMD="start-instances"
    _checkStatus
    result=$(run_command $CMD)
    echo $result
}
function stop {
    CMD="stop-instances"
    _checkStatus
    result=$(run_command $CMD)
    echo $result
}

function shadow(){
    status=$(getStatus)
    if [ $status = "running" ]
        then
        _printConfig
    else
        _log "Not runnning, starting ...\n"
        start
        sleep 5
        shadow
    fi
}

function _printConfig(){
    IP=$(getIp)
    _log "Using IP: $IP\n"      
    FILE="/etc/shadowsocks/aws.json"
    cat >tmpfile.tmp <<EOL 
{
    "server":"$IP",
    "server_port":8000,
    "password":"PASS",
    "method":"aes-256-cfb",
    "local_address": "127.0.0.1",
    "local_port":1180,
    "timeout":300,
    "fast_open": false,
    "workers": 1,
    "prefer_ipv6": false
}   
EOL
    _log "Writing Config\n"
    sudo mv tmpfile.tmp $FILE 
    _log "Starting ShadowsSocks\n"
    sudo systemctl restart shadowsocks@aws
}

if [ -z "$1" ]
    then
    _log "\n Possible commands: status|start|stop|ip|shadow \n\n"
else
    if [ $1 = "start" ] 
        then
        start
    elif [ $1 = "stop" ] 
        then
        stop
    elif [ $1 = "status" ] 
        then
        getStatus   
    elif [ $1 = "ip" ]
        then
        getIp
    elif [ $1 = "shadow" ]
        then
        shadow
    fi
fi
