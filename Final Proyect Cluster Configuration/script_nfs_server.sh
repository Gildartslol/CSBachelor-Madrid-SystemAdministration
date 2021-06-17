#!/bin/bash

echo "CONFIG : Comenzando la configuración del NFS"

#Comprobamos si el fichero pasado es correcto
line=$(wc -l < $1)
if [ $line -lt 1 ]; then
    echo "CONFIG : Número de lineas incorrectas "
    exit 1;
fi

echo "CONFIG : Preparando la configuracion del servicio NFS "
echo "CONFIG  : Actualizando paquetes"
apt-get -y update > /dev/null 2>&1  
echo "CONFIG : Instalando la herramienta NFS "
export DEBIAN_FRONTEND=noninteractive #le decimos a apt que no va a ser usado de forma interactiva
apt-get -qq -y update > /dev/null 2>&1 
apt-get -qq -y install nfs-common > /dev/null 2>&1
apt-get -qq -y install nfs-kernel-server > /dev/null 2>&1
echo "CONFIG : Terminado"
#inicio del bucle

while read sentence; do
    newline="$sentence *(rw,sync,crossmnt,no_subtree_check)" 
    grep -F -x -q "$newline" /etc/exports && echo "CONFIG : Directorio ya exportado"
    if [ $? -ne 0 ];then
	echo $newline  >> /etc/exports
    fi
   # echo "$sentence *(rw,sync,crossmnt,no_subtree_check)" >> /etc/exports 
done <$1

/etc/init.d/nfs-kernel-server restart 
echo "CONFIG : Configuracion terminada correctamente"
exit 0;