#!/bin/bash
###############################################################################
# Script para respaldo de sitios web en servidor Linux con apache.
# Versión: 0.1
#
# Uso: $ ./script_respaldo_sitio.sh <ARCHIVO.CSV>
#
# ARCHIVO.CSV
# - Este achivo contiene la información de los sitios, sobre los cuales se
#   llevarán a cabo los respaldos.
# - Debe de contener las siguientes columnas de información de los sitios.
#   - Estatus
#   - Nombre
#   - Ruta absoluta a los archivos
#   - Nombre de la base de datos
#   - Host o IP del servidor de base de datos
#   - Usuario de la base de datos
#   - Contraseña del usuario de la base de datos
#
# Autor: jorge@integraci.com.mx
#
# Licencia:
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
###############################################################################

# Variables
DIRECTORIO_RESPALDOS="/var/www/respaldos"
DIRECTORIOS_TEMPORALES="/tmp"

###############################################################################
# Archivo de datos de control en formato CSV separado por coma simple ','
ARCHIVO=$1

# En caso de no no indicar el archivo con la información terminar el script.
if [ ! -n "${ARCHIVO}" ]; then
   echo -ne "\n\e[1;31mNo indicó el archivo con la información de los sitios a respaldar\e[0m\n\n"
   exit
fi

# En caso de no existir el archivo terminar la ejecución del script
if [ ! -f $ARCHIVO ]; then
   echo -ne "\n\e[1;31mNo es un archivo, favor de verificar.\e[0m\n\n"
   exit
fi

# Eliminar retorno de carro de archivo
sed -i 's/\x0D$//' $ARCHIVO

# En caso de no existir el directorio de respaldos este se creará
if [ ! -d $DIRECTORIO_RESPALDOS ]; then
   mkdir $DIRECTORIO_RESPALDOS
   echo -ne "\n\e[1;32mSe ha creado el directorio - $DIRECTORIO_RESPALDOS \e[0m\n\n"
fi

###############################################################################
# Ciclo sobre el archivo CSV con la información de los sitios a respaldar
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

   ############################################################################
   # Información del sitio
   ESTATUS_SITIO=$(echo $LINEA | awk -F ',' '{print $1}')
   NOMBRE_SITIO=$(echo $LINEA | awk -F ',' '{print $2}')
   RUTA_ARCHIVOS_SITIO=$(echo $LINEA | awk -F ',' '{print $3}')
   RUTA_DIRECTORIO_SITIO=${RUTA_ARCHIVOS_SITIO%/*}
   DIRECTORIO_SITIO=${RUTA_ARCHIVOS_SITIO##*/}
   BASE_DATOS_SITIO=$(echo $LINEA | awk -F ',' '{print $4}')
   HOST_BD_SITIO=$(echo $LINEA | awk -F ',' '{print $5}')
   USUARIO_BD_SITIO=$(echo $LINEA | awk -F ',' '{print $6}')
   CONTRASENA_USUARIO_BD_SITIO=$(echo $LINEA | awk -F ',' '{print $7}')

   ############################################################################
   # Validación que exista información del Nombre del Sitio
   if [ -z "${NOMBRE_SITIO}" ] ; then
      echo -ne "\e[1;37mLínea no. $CONTADOR, archivo $ARCHIVO\e[0m\n"
      echo -ne "\e[1;31mNo se proporciona el nombre del sitio\e[0m\n\n"
      continue
   fi
   echo -ne "\e[1;32mNombre del sitio:\t\e[1;37m$NOMBRE_SITIO\e[0m\n"

   # Validación que existan información del Estaus del Sitio
   if [ -z "${ESTATUS_SITIO}" ] ; then
      echo -ne "\e[1;37mLínea no. $CONTADOR, archivo $ARCHIVO\e[0m\n"
      echo -ne "\e[1;31mNo se proporciona el estatus del sitio\e[0m\n\n"
      continue
   fi
   echo -ne "\e[0;32mEstatus:\t\t\e[0;37m$ESTATUS_SITIO\e[0m\n"

   # Validación que existan información de la ruta de a los archivos del sitio
   if [ -z "${RUTA_ARCHIVOS_SITIO}" ] ; then
      echo -ne "\e[1;37mLínea no. $CONTADOR, archivo $ARCHIVO\e[0m\n"
      echo -ne "\e[1;31mNo se proporciona la ruta a los archivos del sitio\e[0m\n\n"
      continue
   fi
   echo -ne "\e[0;32mRuta de archivos:\t\e[0;37m$RUTA_ARCHIVOS_SITIO\e[0m\n"

   # Validación sea absoluta la ruta a los archivos del sitio
   if [[ $RUTA_ARCHIVOS_SITIO != "/"* ]] ; then
      echo -ne "\e[1;37mLínea no. $CONTADOR, archivo $ARCHIVO\e[0m\n"
      echo -ne "\e[1;31mNo se proporciona la ruta absoluta a los archivos del sitio\e[0m\n\n"
      continue
   fi

   # Validación que existan información del directorio de archivos del sitio
   if [ -z "${DIRECTORIO_SITIO}" ] ; then
      echo -ne "\e[1;37mLínea no. $CONTADOR, archivo $ARCHIVO\e[0m\n"
      echo -ne "\e[1;31mNo se identifica el directorio de los archivos del sitio\e[0m\n\n"
      continue
   fi
   echo -ne "\e[0;32mDirectorio Sitio:\t\e[0;37m$DIRECTORIO_SITIO\e[0m\n"

   # Validación que existan información de la ruta al directorio del sitio
   if [ -z "${RUTA_DIRECTORIO_SITIO}" ] ; then
      echo -ne "\e[1;37mLínea no. $CONTADOR, archivo $ARCHIVO\e[0m\n"
      echo -ne "\e[1;31mNo se identifica la ruta al directorio del sitio favor de verificar la ruta de los archivos del sitio, no debe de estar en raiz del sistema el directorio de archivos del sitio \"/SITIO\" o finalizar con diagonal \"/SITIO/\"\e[0m\n\n"
      continue
   fi
   echo -ne "\e[0;32mRuta al directorio:\t\e[0;37m$RUTA_DIRECTORIO_SITIO\e[0m\n"

   # Validación que existan información de la base de datos
   if [ -z "${BASE_DATOS_SITIO}" ] ; then
      echo -ne "\n\e[1;37mLínea no. $CONTADOR, archivo $ARCHIVO\e[0m\n"
      echo -ne "\e[1;33mNo hay información de base de datos se hará solamente el respaldo de archivos.\e[0m\n\n"
   else
      echo -ne "\e[0;32mBase de Datos:\t\t\e[0;37m$BASE_DATOS_SITIO\e[0m\n"

      if [ -z "${HOST_BD_SITIO}" ] ; then
         echo -ne "\n\e[1;37mLínea no. $CONTADOR, archivo $ARCHIVO\e[0m\n"
         echo -ne "\e[1;31mNo hay información del host de la base de datos\e[0m\n\n"
         continue
      fi

      if [ -z "${USUARIO_BD_SITIO}" ] ; then
         echo -ne "\n\e[1;37mLínea no. $CONTADOR, archivo $ARCHIVO\e[0m\n"
         echo -ne "\e[1;31mNo hay información del usuario de la base de datos\e[0m\n\n"
         continue
      fi
      echo -ne "\e[0;32mUsuario BD:\t\t\e[0;37m$USUARIO_BD_SITIO\e[0m\n"

      if [ -z "${CONTRASENA_USUARIO_BD_SITIO}" ] ; then
         echo -ne "\n\e[1;37mLínea no. $CONTADOR, archivo $ARCHIVO\e[0m\n"
         echo -ne "\e[1;31mNo hay información de la contraseña de la base de datos\e[0m\n\n"
         continue
      fi
      echo -ne "\e[0;32mContraseña:\t\t\e[0;37m$CONTRASENA_USUARIO_BD_SITIO\e[0m\n\n"
   fi

   ############################################################################
   # Inicio de actividades de respaldo de sitio

   # Marca de tiempo del respaldo
   FECHA_RESPALDO=$(date '+%Y_%m_%d__%H_%M')

   # Directorio de Trabajo
   DIR_TRABAJO="$DIRECTORIOS_TEMPORALES/$DIRECTORIO_SITIO-$FECHA_RESPALDO"
   mkdir $DIR_TRABAJO

   # Respaldo de archivos de sitio web
   tar -czvf $DIR_TRABAJO/${DIRECTORIO_SITIO}-$FECHA_RESPALDO.tgz -C $RUTA_DIRECTORIO_SITIO $DIRECTORIO_SITIO

   # Respaldo de bases de datos en MariaDB o MySQL
   if [ -n "${BASE_DATOS_SITIO}" ] ; then
      mysqldump -u $USUARIO_BD_SITIO -p$CONTRASENA_USUARIO_BD_SITIO -h $HOST_BD_SITIO --default-character-set=utf8 $BASE_DATOS_SITIO > $DIR_TRABAJO/$BASE_DATOS_SITIO-$FECHA_RESPALDO.sql
      tar -czvf $DIR_TRABAJO/$BASE_DATOS_SITIO-$FECHA_RESPALDO.sql.tgz -C $DIR_TRABAJO $BASE_DATOS_SITIO-$FECHA_RESPALDO.sql
      rm -f $DIR_TRABAJO/$BASE_DATOS_SITIO-$FECHA_RESPALDO.sql
   fi

   # Respaldo de configuración de servicios
   tar -zcvf $DIR_TRABAJO/configuracion-servidor-$FECHA_RESPALDO.tgz /etc/hosts /etc/php.ini /etc/my.cnf /etc/httpd

   # Cambiamos permisos
   chown root.root $DIR_TRABAJO -R
   find $DIR_TRABAJO -type d -exec chmod 700 {} \;
   find $DIR_TRABAJO -type f -exec chmod 400 {} \;

   # Creación de archivo con firmas de archivos de respaldo para verificación de integridad
   md5sum $DIR_TRABAJO/* > $DIR_TRABAJO/md5sum-$FECHA_RESPALDO.txt  

   # Mover directorio de trabajo a directorio de respaldos
   mv $DIR_TRABAJO $DIRECTORIO_RESPALDOS/

done < $ARCHIVO

echo -ne "\n\n"

###############################################################################
