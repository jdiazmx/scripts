#!/usr/bin/sh

###############################################################################
#
# Script para leer un archivos CSV conteniendo los ID de los videos de 
# youtube para ser descargados con youtube.dl
#
# La primera columna del archivo "CSV" contiene el ID del video
# 
# https://www.youtube.com/watch?v=XXXXXXXXXXX
#                                 ^----ID---^
# 
# Autor: Jorge Diaz - jorge.diaz@gmail.com
#
# Licencia GPL V3
#
###############################################################################

DIRECTORIO_VIDEOS=videos

# Archivo de datos de control en formato CSV separado por coma simple ','
ARCHIVO=$1

# En caso de no no indicar el archivo con la información terminar el script.
if [ ! -n "${ARCHIVO}" ]; then
   echo -ne "\n\e[1;31mNo indicó el archivo con la información de los videos a descargar\e[0m\n\n"
   exit 1
fi

# En caso de no existir el archivo terminar la ejecución del script
if [ ! -f $ARCHIVO ]; then
   echo -ne "\n\e[1;31mNo es un archivo, favor de verificar.\e[0m\n\n"
   exit 1
fi

# Eliminar retorno de carro de archivo
sed -i 's/\x0D$//' $ARCHIVO

# En caso de no existir el directorio en el que se descargarán los videos
if [ ! -d $DIRECTORIO_VIDEOS ]; then
   mkdir $DIRECTORIO_VIDEOS
   echo -ne "\n\e[1;32mSe ha creado el directorio - $DIRECTORIO_VIDEOS \e[0m\n\n"
fi

###############################################################################
# Ciclo sobre el archivo CSV con la información de los videos a descargar
###############################################################################

# Contador para identificar la línea del archivo que se está ejecutando
CONTADOR=0

# Leemos línea por linea el archivo que contiene la información de los sitios
while read LINEA
do
   let CONTADOR=$CONTADOR+1

   # Saltar el encabezado de las columnas del archivo CSV
   if [ $CONTADOR -eq 1  ]; then
      continue
   fi

   # Extrae la información de la primer columna del archivo.
   ID_VIDEO=$(echo $LINEA | awk -F ',' '{print $1}')
   
   # Validación que exista información del Nombre del Sitio
   if [ -z "${ID_VIDEO}" ] ; then
      echo -ne "\e[1;37mLínea no. $CONTADOR, archivo $ARCHIVO\e[0m\n"
      echo -ne "\e[1;31mNo se proporciona el nombre del sitio\e[0m\n\n"
      continue
   fi
   echo -ne "\e[1;32mId del video:\t\e[1;37m$ID_VIDEO\e[0m\n"

   youtube-dl -f bestvideo+bestaudio/best ${ID_VIDEO}


   ############################################################################


done < $ARCHIVO

echo -ne "\n\n"
