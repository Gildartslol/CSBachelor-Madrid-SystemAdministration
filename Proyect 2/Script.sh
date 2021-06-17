#!/bin/bash
#Comprobamos si debemos poner el valor por defecto, que es 5 o si debemos usar el valor pasado por parametro.
if [ $# -lt 3 ]
then 
U=5
else
U=$3
fi

if [ $# -lt 5 ]
then 
G=$1
sudo groupadd $1
else
G=$5
sudo groupadd $5
fi
#En este momento tenemos en la variable N el numero de usuarios a crear y en la variable G el nombre del grupo donde vamos a meter a los usuarios.
N=1
while [ $U -gt 0 ] 
do
	User=$1$N
	U=$((U-1))  #Decrementamos en 1 el numero de usuarios a crear
	N=$((N+1))  #Incrementamos en 1 para poder formar los usuarios pedidos
	sudo useradd $User -m
	if [ $? = 9 ];then
		echo "El usuario ya existe, se ha movido al grupo $G"
		sudo usermod -a -G $G $User
			#añadir dicho usario al grupo
		else
		sudo usermod -a -G $G $User
		echo "Usuario $User creado y movido al grupo $G"
	fi
done
