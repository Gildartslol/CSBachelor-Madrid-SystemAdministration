
#!/bin/bash
#Comprobamos que el fichero de configuracion es correcto
LINE=$(wc -l < $1)
if [ $LINE -ne 3 ]; then
	echo "CONFIG : El fichero de configuracion no contiene el numero de lineas adecuado"
	exit 1;
fi

NAME=$(sed -n 1p $1)
LEVEL=$(sed -n 2p $1)
DEVICES=$(sed -n 3p $1)
if [[ "$LEVEL" != "1" && "$LEVEL" != "4" && "$LEVEL" != "5" && "$LEVEL" != "6" && "$LEVEL" != "10" ]]; then
    echo "CONFIG : Nivel de raid invalido: $LEVEL "
    exit 1;
fi

#Para el numero de dispositivos
DEVICESCONF=( $DEVICES )

echo "CONFIG : Preparando la configuracion del servicio raid "
echo "CONFIG  : Actualizando paquetes"
apt-get -y update > /dev/null 2>&1  
echo "CONFIG : Instalando la herramienta mdadm "
export DEBIAN_FRONTEND=noninteractive
apt-get -qq -y install mdadm --no-install-recommends 
echo "CONFIG : Terminado"
#montamos el raid
echo "CONFIG : Montando el raid ... "
#-R importantisimo para que no pregunte nada, fuerza a construir siempre.
mdadm --create -R -q --level=$LEVEL --raid-devices=${#DEVICESCONF[*]} $NAME $DEVICES > /dev/null 2>&1
if [ $? -ne 0 ];then
    echo "CONFIG : Error en el creado del raid "
    exit 1;
 else
	echo "CONFIG : Configuración del raid terminada correctamente "
	exit 0;
fi
