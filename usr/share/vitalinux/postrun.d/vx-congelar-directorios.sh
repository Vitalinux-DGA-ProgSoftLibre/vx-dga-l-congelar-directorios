#!/bin/bash
#Diseñado por Arturo Martín
#Proyecto Piloto DGA

USUARIO=$(vx-usuario-grafico)
ejecutor=$(whoami)

if [ -z $USUARIO ] ; then
	echo `date` "Usuario sin especificar. Salimos"
	exit 1
fi

HOMEUSUARIO="$(getent passwd | grep "${USUARIO}:" | cut -d":" -f6)"
if [ -z $HOMEUSUARIO ] ; then
	echo `date` "CONDIR: Home sin especificar. Salimos"
	exit 1
fi

#if test "$ejecutor" != "root" ; then
#	exit 1
#fi

echo "Proceso de congelación del Perfil para el usuario $USUARIO - $ejecutor - $(date)" > ${HOMEUSUARIO}/info-congelacion-perfil.txt
# Cuidamos por directorios con espacios
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for DIRECTORIO in $(ls /etc/skel-directorios-congelados/ -a | egrep -v "^\.?\.$") ; do
	if rsync --delete -rl /etc/skel-directorios-congelados/$DIRECTORIO ${HOMEUSUARIO} ; then
		echo " --> OK: Se ha sincronizado el directorio $DIRECTORIO del usuario $USUARIO ..." >> ${HOMEUSUARIO}/info-congelacion-perfil.txt
	else
		echo " --> ERROR: No se ha sincronizado el directorio $DIRECTORIO del usuario $USUARIO ..." >> ${HOMEUSUARIO}/info-congelacion-perfil.txt
	fi
	chown -R $USUARIO.sudo ${HOMEUSUARIO}/$DIRECTORIO
done
IFS=$SAVEIFS
