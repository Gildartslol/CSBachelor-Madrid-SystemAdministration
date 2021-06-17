#!/bin/bash

echo "CONFIG : Comenzando la configuración del montaje"

#Comprobamos si el fichero pasado es correcto
line=$(wc -l < $1)
echo "$line"
if [ $line -ne 2 ]; then
    echo "CONFIG : Número de lineas incorrectas "
    exit 1;
fi
DEVICE=$(sed -n 1p $1)
POINT=$(sed -n 2p $1)
#Cogemos el nombre del dispositivo, hacemos con rev para coger siempre el ultimo.
SUBSTRING=$(echo $DEVICE | rev | cut -d"/" -f 1 | rev)

#Comprobamos que el dispositivo existe
grep -q $SUBSTRING /proc/partitions
if [ $? -ne 0 ]; then
    echo "CONFIG : El dispositivo $DEVICE no existe"
    exit 1;
fi
#Comprobar si esta montado ya, y sino lo monta.
mountpoint -q $POINT
if [ $? -eq 1 ]; then  #No esta montado
	echo "CONFIG : Limpiando directorio y montando"
	if [ -d "$POINT" ]; then  #Directorio existe
	    #Comprobamos si esta vacio
	    shopt -s nullglob dotglob
	    files=($POINT/*)
	    if [ ${#files[@]} -gt 0 ];then
		echo "CONFIG : Error,el directorio no esta vacío pudiendo haber archivos ocultos"
		exit 1;
	    fi
	    mount $DEVICE $POINT
	    if [ $? -ne 0 ]; then
		echo "CONFIG : Error de montado, el dispositivo no puede ser montado"
		exit 1;
	    fi
	 else  #No existe
	    echo "CONFIG : Creando directorio y montando..."
	    mkdir $POINT
	    mount $DEVICE $POINT
	    if [ $? -ne 0 ]; then
		echo "CONFIG : Error de montado, el dispositivo no puede ser montado"
		exit 1;
	    fi
        fi
else
    echo "CONFIG : Error de montado,el directorio $POINT ya está siendo usado como punto de montaje "
    exit 1;
fi

#Configuramos fstab para que se monte siempre
grep -q "$DEVICE\s*$POINT\s*auto\s*defaults\s*,\s*auto\s*,\s*rw\s*0\s*0" /etc/fstab
if [ $? -eq 1 ]; then
	echo "#Device: $DEVICE" >> /etc/fstab && echo "$DEVICE $POINT auto defaults,auto,rw 0 0" >> /etc/fstab && echo "CONFIG: Configurado para montaje automático  al inicio"
else
          echo "CONFIG : Mandatos ya configurados previamente"
fi

echo "CONFIG : Configuración del montaje terminada correctamente"
exit 0;
