#!/bin/bash

# root

echo "copy root starter files to /home/root/bin"

cp /home/root/setup/appuser/bin/* /home/root/bin/
chmod 775 /home/root/bin/*.sh

# nginx
mkdir -p /home/appuser/var/lib/nginx/logs/
mkdir -p /home/root/etc/nginx/

cp /home/root/setup/appuser/etc/nginx/* /home/root/etc/nginx/

# mysql
mkdir -p /home/appuser/var/lib/mysql/datadir/
mkdir -p /home/appuser/var/lib/mysql/log/
mkdir -p /home/appuser/var/lib/mysql/tmp/
mkdir -p /home/root/etc/mysql/

cp /home/root/setup/appuser/etc/mysql/* /home/root/etc/mysql/

# geth
mkdir -p /home/appuser/var/lib/geth/datadir/
mkdir -p /home/root/etc/geth/

cp /home/root/setup/appuser/etc/geth/* /home/root/etc/geth/




# appuser

echo "copy user launcher files to /home/appuser/usr/local/bin"

mkdir -p /home/appuser/usr/local/bin/
cp /home/root/setup/appuser/usr/local/bin/* /home/appuser/usr/local/bin/
chmod 775 /home/appuser/usr/local/bin/*.sh


# ethereum_reader_server
mkdir /home/appuser/var/lib/ethereum_reader_server
mkdir /home/appuser/var/lib/ethereum_reader_server/logs
mkdir /home/appuser/var/lib/ethereum_reader_server/settings
echo "{\"service_name\": \"ethereum reader service\",\"server_listening_port\": 13000}" > /home/appuser/var/lib/ethereum_reader_server/settings/config.json

# ethereum_webapp
echo "import standard pod settings"

. /home/root/bin/pod.config



echo "overload from pod execution environment"

echo "environment variables are:"
env

while IFS='=' read -r name value ; do
  if [[ $name == 'POD_'* ]]; then
#    echo "$name" ${!name}
    newname=${name#"POD_"}
    val=${!name}

    declare $newname=${val}
    echo "$newname=" ${!newname}

  fi
done < <(env)


echo "writing launch.config"

echo "# generated on "$(date '+%d/%m/%Y %H:%M:%S') > /home/appuser/launch.config

while IFS='=' read -r name value ; do
  if [[ $name == 'LAUNCH_CONFIG_'* ]]; then
#    echo "$name" ${!name}
    newname=${name#"LAUNCH_CONFIG_"}
#   echo "$newname" ${!name}

    printf "$newname=${!name}\n" >> /home/appuser/launch.config
  fi
done < <(set -o posix ; set)

echo "writing config.json"

while IFS='=' read -r name value ; do
  if [[ $name == 'config_json_'* ]]; then
#    echo "$name" ${!name}
    newname=${name#"config_json_"}
#    echo "$newname" ${!name}

    jsonarr=(${jsonarr[@]} $newname ${!name})
  fi
done < <(set -o posix ; set)

mkdir -p /home/appuser/var/lib/ethereum_webapp/logs
mkdir -p /home/appuser/var/lib/ethereum_webapp/settings

echo "{}" > /home/appuser/var/lib/ethereum_webapp/settings/config.json

jsonstring='{'$(printf '\"%s\": \"%s\",' "${jsonarr[@]}")'"end_of_json":"1"}'
#echo $jsonstring | > /home/appuser/var/lib/ethereum_webapp/settings/config.json.test
echo $jsonstring | jq . > /home/appuser/var/lib/ethereum_webapp/settings/config.json


# give ownership of all directories to LAUNCH_CONFIG_USERID
chown -R $LAUNCH_CONFIG_USERID:$LAUNCH_CONFIG_USERID /home/appuser

# give ownership of /home/appuser/var/lib/mysql directories to mysql
touch /home/appuser/var/lib/mysql/log/mysql.log
chown -R mysql:mysql /home/appuser/var/lib/mysql

# give ownership of /home/appuser/var/lib/geth directories to geth
chown -R geth:geth /home/appuser/var/lib/geth



