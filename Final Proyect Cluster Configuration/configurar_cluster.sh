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
#Aqui se usa la version menos eficiente que es recorrer todo el array y comprobar que existe, mas eficiente seria hacer una copia del array e intentar borrar lo que queramos, si lo hace esta.
containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

#Comprobación de argumentos
if test "$#" -ne 1; then
    echo "Uso: $0 <fichero_configuracion>"
    exit 1
fi
echo "Comenzando la configuración..."
#Si nuestro fichero auxiliar ya existe, lo truncamos
if [ -e fichero_new_conf ]; then
  truncate -s 0 fichero_new_conf
else
  echo >> $1
fi
#Copiando nuestro archivo de configuracion original en un nuevo para modificarlo
cat $1 >> fichero_new_conf
#Eliminando lineas en blanco y comentarios de nuestro nuevo fichero de configuracion
sed -i '/^\s*$/d' fichero_new_conf 
sed -i '/^#/ d' fichero_new_conf
#Comprobar numero de parametros correctos en fichero de configuración
services=("mount" "raid" "lvm" "nis_server" "nis_client" "nfs_client" "nfs_server" "backup_client" "backup_server");
ficherosConf=("mount_raid.conf" "raid.conf" "nfs_server.conf" "nfs_client.conf");
line=$((1))
while read sentence; do
    
	MASENTENCE=$sentence
	VAR=$sentence
	VAR=( $VAR )
	#En num tenemos el numero de argumentos de la sentencia de configuracion, esto servira para ver si falta alguno de los tres parametros.
	NUM=${#VAR[@]}
	if [ $NUM -lt 3 ]; then
		echo "CONFIG: Falta algún parámetro de configuracion en la linea : " && grep -n "$MASENTENCE" $1 | grep -Eo '^[^:]+'
		exit 1;
	fi
	iteration=$((0))
	for word in $sentence; do
			#Para el primer parametro comprobamos su formato, es decir, un ip correcto.	
		    if [ $iteration -eq 0 ]; then
		    	if valid_ip $word; then stat='good '; 
		    	else stat='bad'
		    		echo "CONFIG : La ip $word no esta definida en el formato correcto "
		    		exit 1;
		    	 fi
		    fi  
		    #Para el segundo parametro comprobamos que el servicio que pide es correcto.
		    if [ $iteration -eq 1 ]; then
		    	containsElement "$word" "${services[@]}"; 
		    	if [ $? -eq 1 ]; then 
		    		echo "CONFIG : El servicio $word no esta definido "
				exit 1;
		    	fi
		    fi
		    #Para el tercer parametro comprobamos que el fichero de configuración tiene el nombre adecuado.
	           # if [ $iteration -eq 2 ]; then
	    	    #containsElement "$word" "${ficherosConf[@]}"; 
		    #	if [ $? -eq 1 ]; then 
		    #	    echo "CONFIG : Fichero de configuracion definido erroneamente :  $word"
			#	exit 1;
		    #	fi
		    # fi
	   
    	iteration=$((iteration+1))  
	done  
done <fichero_new_conf

echo "Fichero de configuración validado correctamente"
while read sentence;do
    echo "$sentence"
done  <fichero_new_conf

while read -u10 sentence; do
	echo $sentence
	LINE=( $sentence )
	#Máquina destino
		HOST=${LINE[0]}
		#Nombre servicio
		SERVICE=${LINE[1]}

		case $SERVICE in
		mount )
			SCRIPT=script_mount.sh
			;;
		raid )
			SCRIPT=script_raid.sh
			;;
		lvm )
			SCRIPT=script_lvm.sh
			;;
		nis_server )
			SCRIPT=script_nis_server.sh
			;;
		nis_client )
			SCRIPT=script_nis_client.sh
			;;
		nfs_server )
			SCRIPT=script_nfs_server.sh
			;;
		nfs_client )
			SCRIPT=script_nfs_client.sh
			;;
		backup_server )
			SCRIPT=script_backup_server.sh
			;;
		backup_client )
			SCRIPT=script_backup_client.sh
			;;
		*)
			echo "CONFIG: Error en el servicio indicado ($SERVICIO). Abortando..."
			exit 1
			;;
		esac
	echo "Vamos a ejecutar el script $SCRIPT"
			#Ruta del fichero perfil configuración
		CONF=${LINE[2]}
		echo 'CONFIG: Fichero de perfil de configuración del servicio: '$CONF
		#Diretorio temporal para guardar archivos
		echo 'CONFIG: Preparando archivos...'
		ssh root@$HOST 'mkdir ~/ASI2015/' > /dev/null 2>&1 || { echo "CONFIG: Error al conectar con la máquina objetivo. Abortando" ; exit 1; }
		scp $CONF root@$HOST:~/ASI2015/$CONF > /dev/null 2>&1
		scp $SCRIPT root@$HOST:~/ASI2015/$SCRIPT > /dev/null 2>&1
		#Ejecutamos el servicio
		ssh root@$HOST "chmod +x ~/ASI2015/$SCRIPT" > /dev/null 2>&1
		ssh root@$HOST "~/ASI2015/$SCRIPT ~/ASI2015/$CONF" 2>&1
		#Eliminamos los ficheros de configuración temporales utilizados
		ssh root@$HOST 'rm -r ~/ASI2015/' > /dev/null 2>&1

done 10<fichero_new_conf

echo "CONFIG : Servicios ejecutados correctamente"


