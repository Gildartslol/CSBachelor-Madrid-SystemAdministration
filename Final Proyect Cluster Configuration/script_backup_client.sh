#!/bin/bash
function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

echo " CONFIG : Comenzamos la configuracion del back up en el cliente"
#Comprobamos que el fichero de configuracion es correcto
LINE=$(wc -l < $1)
if [ $LINE -ne 4 ]; then
	echo "CONFIG : El fichero de configuracion no contiene el numero de lineas adecuado"
	exit 1;
fi

DIR_ORIGEN=$(sed -n 1p $1)
SERVER=$(sed -n 2p $1)
DIR_DESTINO=$(sed -n 3p $1)
TIME_IN_HOURS=$(sed -n 4p $1)

#Comprobamos que es una ip valida
if valid_ip $SERVER; 
	then 
    echo "CONFIG : IP valida."
else 
	echo "CONFIG : La ip $word no esta definida en el formato correcto"
	exit 1;
 fi  

#Comprobando si el directorio a realizar el backup existe
if [ ! -d "$DIR_ORIGEN" ]; then
  	echo "CONFIG : El directorio no existe, abortando"
  	exit 1;
fi

echo "CONFIG : Actualizando paquetes e instalando rsync ..."
apt-get -y update > /dev/null 2>&1 
export DEBIAN_FRONTEND=noninteractive
apt-get -qq -y install rsync --no-install-recommends > /dev/null 2>&1 
#En el minuto 0, cade timeinhours horas, de cada dia del mes, de cada mes, todos los dias.
echo "00 $TIME_IN_HOURS * * * root rsync --recursive $DIR_ORIGEN $SERVER:$DIR_DESTINO " >> /etc/crontab && echo "CONFIG : Backup configurado correctamente "
exit 0;
