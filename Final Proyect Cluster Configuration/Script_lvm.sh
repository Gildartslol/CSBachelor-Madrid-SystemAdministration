#!/bin/bash

echo "CONFIG : Comenzando la configuración del lvm2"

#Comprobamos si el fichero pasado es correcto
line=$(wc -l < $1)
if [ $line -lt 3 ]; then
    echo "CONFIG : Número de lineas incorrectas "
    exit 1;
fi

echo "CONFIG : Preparando la configuracion del servicio lvm "
echo "CONFIG  : Actualizando paquetes"
apt-get -y update > /dev/null 2>&1  
echo "CONFIG : Instalando la herramienta lvm2 "
export DEBIAN_FRONTEND=noninteractive
apt-get -qq -y install lvm2 --no-install-recommends 
echo "CONFIG : Terminado"
#inicio del bucle
C=1
while read sentence; do
   if [ $C -eq 1 ];then
      GROUP_NAME=$(sed -n 1p $1)
       DEVICES=$(sed -n 2p $1)
       echo "CONFIG : Inicializamos los voluménes físicos $DEVICES"
       pvcreate $DEVICES  > /dev/null 2>&1
   fi

   if [ $C -eq 2 ];then
       echo "CONFIG : Creamos el grupo $NAME "
       vgcreate $GROUP_NAME $DEVICES  > /dev/null 2>&1
   fi

   if [ $C -gt 2 ];then
       LINE=( $sentence )
       VOLUME_NAME=${LINE[0]}
       SIZE=${LINE[1]}
       echo "CONFIG : Creando el volumen lógico $VOLUME_NAME con tamaño $SIZE"
        lvcreate --name $VOLUME_NAME --size $SIZE $GROUP_NAME > /dev/null 2>&1 
       if [ $? -ne 0 ];then
	   echo "CONFIG : Error creando el volumen $VOLUME_NAME"
	   exit 1;
       else
	 echo "CONFIG : El volumen $VOLUME_NAME se ha creado satisfactoriamente"  
       fi
   fi
    
    let C+=1
done <$1
echo "CONFIG : Volúmenes creados correctamente"
exit 0;