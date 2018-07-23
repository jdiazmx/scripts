#!/bin/bash
###############################################################################
# Nombre: crea_bridge.sh 
# Descripción: Script para la creación de puente de red en Fedora/RHEL/CentO
# Última Modificación: 23/07/2018
#
# Autor: Jorge A. Díaz Lara - jorge@integraci.com / jorge.diaz@gmail.com
# Licencia: GPL Versión 2
###############################################################################

# Detección de usuario, se debe ejecutar como usuario root
if [[ $EUID -ne 0 ]]; then
    echo -ne "\nPor favor ejecuta el script como usuario \"root\".\n"
    exit 1
fi

# Creamos el archivo de configuración del puente de red
cat <<FIN> /etc/sysconfig/network-scripts/ifcfg-br0
DEVICE=br0
TYPE=Bridge
IPADDR=DIRECCION_IP
PREFIX=MASCARA_RED
GATEWAY=PUERTA_ENLACE
DNS1=DNS_1
BOOTPROTO=none
ONBOOT=yes
NM_CONTROLLED=no
DELAY=0
DEFROUTE=yes
NAME=br0
FIN

# Tarjeta de Red 
for ARCHIVO_TARJETA in `find /etc/sysconfig/network-scripts/ -name "ifcfg-e[[:alnum:]]*[[:digit:]]"`;do

  # Limpiamos de caracteres de salto el archivo
  sed -i 's/\x0D$//' $ARCHIVO_TARJETA

  # Identificamos el nombre del archivo de la tarjeta de Ethernet
  NOMBRE_ARCHIVO="`basename ${ARCHIVO_TARJETA%ifcfg}`"

  # Respalda el archivo de configuración 
  cp $ARCHIVO_TARJETA ~/$NOMBRE_ARCHIVO-$(date "+%Y%m%d-%H%M%S").bk

  # Leemos el contenido de los valores del archivo de configuración
  source $ARCHIVO_TARJETA

  # Limpiamos el archivo de configuración de la tarjeta de red
  cat /dev/null > $ARCHIVO_TARJETA

  # Copiamos valores de configuración para el archivo de la tarjeta Ethernet
  echo "DEVICE=${NAME}" >> $ARCHIVO_TARJETA
  echo "TYPE=Ethernet"  >> $ARCHIVO_TARJETA
  echo "BOOTPROTO=none"  >> $ARCHIVO_TARJETA
  echo "NAME=${NAME}" >> $ARCHIVO_TARJETA
  echo "UUIDE=${UUID}" >> $ARCHIVO_TARJETA
  echo "ONBOOT=yes" >> $ARCHIVO_TARJETA
  echo "NM_CONTROLLED=no" >> $ARCHIVO_TARJETA
  echo "BRIDGE=br0" >> $ARCHIVO_TARJETA

  # Sustituimos los valores del archivo de configuración del punte de red
  sed -i "s/DIRECCION_IP/${IPADDR}/" /etc/sysconfig/network-scripts/ifcfg-br0
  sed -i "s/MASCARA_RED/${PREFIX}/" /etc/sysconfig/network-scripts/ifcfg-br0
  sed -i "s/PUERTA_ENLACE/${GATEWAY}/" /etc/sysconfig/network-scripts/ifcfg-br0
  sed -i "s/DNS_1/${DNS1}/" /etc/sysconfig/network-scripts/ifcfg-br0
done

systemctl disable NetworkManager.service 
systemctl enable network.service

reboot

