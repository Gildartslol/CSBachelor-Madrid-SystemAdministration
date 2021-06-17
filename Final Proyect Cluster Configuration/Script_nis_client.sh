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

echo " CONFIG : Comenzamos la configuracion del cliente nis"
#Comprobamos que el fichero de configuracion es correcto
LINE=$(wc -l < $1)
if [ $LINE -ne 2 ]; then
	echo "CONFIG : El fichero de configuracion no contiene el numero de lineas adecuado"
	exit 1;
fi

DOMAIN_NAME=$(sed -n 1p $1)
SERVER=$(sed -n 2p $1)

#Comprobamos que es una ip valida
if valid_ip $SERVER; 
	then 
    echo "CONFIG : IP valida."
else 
	echo "CONFIG : La ip $word no esta definida en el formato correcto"
	exit 1;
 fi  

echo "CONFIG : Actualiznado paquetes e instalando NIS ..."
apt-get -y update > /dev/null 2>&1 
export DEBIAN_FRONTEND=noninteractive
apt-get -qq -y install nis --no-install-recommends 

#Configuracion de defaultDomain, comprobando que no estaba el servidor ya predefinido en yp.conf
grep -q $DOMAIN_NAME /etc/yp.conf
if [ $? -ne 0 ];then
    echo $DOMAIN_NAME > /etc/defaultdomain && echo "CONFIG: etc/defaultdomain configurado"
    echo "domain $DOMAIN_NAME server $SERVER" >> /etc/yp.conf
    echo "ypserver $SERVER" >> /etc/yp.conf && echo "CONFIG : /etc/yp.conf configurado"
else
    echo "CONFIG : Servidor ya existente en yp.conf"
fi
#Configuracion de archivo nsswitch, aqui lo que se hace es indicar en los distintos paths del archivo, passwd group y shadow que utilizen nis para autenticar.
sed -i 's/NISCLIENT=false/NISCLIENT=true/g' /etc/default/nis 
sed -i 's/passwd:\s*compat/passwd: \tfiles nis/g' /etc/nsswitch.conf
sed -i 's/group:\s*compat/group: \tfiles nis/g' /etc/nsswitch.conf
sed -i 's/shadow:\s*compat/shadow: \tfiles nis/g' /etc/nsswitch.conf
/etc/init.d/nis restart
echo "CONFIG : Configuración del cliente nis terminada correctamente"
exit 0;
