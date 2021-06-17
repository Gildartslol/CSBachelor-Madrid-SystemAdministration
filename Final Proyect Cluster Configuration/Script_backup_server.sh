#!/bin/bash

echo " CONFIG : Comenzamos la configuracion del back up en el servidor"
#Comprobamos que el fichero de configuracion es correcto
LINE=$(wc -l < $1)
if [ $LINE -ne 1 ]; then
	echo "CONFIG : El fichero de configuracion no contiene el numero de lineas adecuado,abortando"
	exit 1;
fi

DIR_ORIGEN=$(sed -n 1p $1)
#Comprobando si el directorio a realizar el backup existe
if [ ! -d "$DIR_ORIGEN" ]; then
  	echo "CONFIG : El directorio no existe, abortando"
  	exit 1;
fi

shopt -s nullglob dotglob     # archivos ocultos
files=($DIR_ORIGEN/*)
if [ ${#files[@]} -gt 0 ]; 
	then echo "CONFIG : El directorio $DIR_ORIGEN pasado como parametro no esta vacio,pueden haber archivos ocultos, abortando";
	exit 1;
fi
echo "CONFIG : Terminado correctamente"
 exit 0;
