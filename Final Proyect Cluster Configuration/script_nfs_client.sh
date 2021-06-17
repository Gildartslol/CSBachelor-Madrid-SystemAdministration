#!/bin/bash
echo "CONFIG : Comenzando la configuración del cliente NFS"

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
echo "CONFIG : Terminado"
#inicio del bucle
echo "CONFIG : Montando directorios remotos en el cliente"
C=0
while read sentence; do
    LINE=( $sentence )
    HOST=${LINE[0]}
    REMOTE_DIR=${LINE[1]}
    LOCAL_DIR=${LINE[2]}
    if [ ! -d $LOCAL_DIR ]; then
	mkdir $LOCAL_DIR
    fi
    mount $HOST:$REMOTE_DIR $LOCAL_DIR > /dev/null 2>&1
    if [ $? -eq 0 ]; then
	echo "$sentence nfs defaults,auto 0 0" >> /etc/fstab
     else
	echo " Config : Error de montaje $sentence "
	let C+=1
     fi
done <$1

if [ $C -ne 0 ];then
    echo "CONFIG: Algun directorio no se montó correctamente "
    exit 1;
else
    echo "CONFIG : Directorios remotos montados correctamente"
    exit 0;
fi