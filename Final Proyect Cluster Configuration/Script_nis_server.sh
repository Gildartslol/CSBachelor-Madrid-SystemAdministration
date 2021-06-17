#! /bin/bash

echo "CONFIG : Comenzando la configuracion de un servidor nis"

#Comprobamos numero de lineas
line=$(wc -l < $1)
if [ $line -ne 1 ]; then
    echo "CONFIG : Numero de lineas incorrectas "
    exit 1;
fi

#Obtenemos nombre del dominio
DOMAINNAME=$(sed -n 1p $1)
SERVER=$(hostname)
echo "CONFIG : Instalando NIS ... "
apt-get -y update > /dev/null 2>&1 
export DEBIAN_FRONTEND=noninteractive
apt-get -qq -y install nis --no-install-recommends 
 #Configurando el directorio defaultdomain
echo "CONFIG : Configurando..."
#Estableciendo nombre del dominio 
echo $DOMINIO > /etc/defaultdomain && echo "CONFIG: etc/defaultdomain configurado"
echo "domain $DOMAINNAME server $SERVER" >> /etc/yp.conf
#Modificando el directorio /default/nis


sed -i s/NISSERVER=false/NISSERVER=true/ /etc/default/nis
sed -i s/NISCLIENT=true/NISCLIENT=false/ /etc/default/nis
 echo "CONFIG : /etc/default/nis configurado"

#Control D para parar inmediatamente
EOF | /usr/lib/yp/ypinit -m > /dev/null

echo "CONFIG : Configuracion completatada,reiniciando el servicio NIS..."
/etc/init.d/nis restart
exit 0;