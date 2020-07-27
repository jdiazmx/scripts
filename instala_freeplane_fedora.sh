#!/bin/sh
###############################################################################
# Instalación de Freeplane - Editor de mapas mentales.                        #
# Para actualizar será necesario ejecutar nuevamente el script.               #
#                                                                             #
# Autor: Jorge Antonio Díaz Lara - jorge.diaz@gmail.com                      #
#                                                                             #   
# Basado en https://fedoramagazine.org/freeplane-swiss-army-tool-your-brain/  #
###############################################################################

# Variables 
VERSION="1.8.6"
URL_DESCARGA="https://cfhcable.dl.sourceforge.net/project/freeplane/freeplane%20stable/freeplane_bin-$VERSION.zip"

verifica_usuario() {
   if [[ $EUID -ne 0 ]]; then
      echo -e "\n\e[1;38;5;202mPara instalar Freeplane para todos los usuarios\nes necesario que seas \"root\".\n"
      exit 1
   fi
}

borra_anteriores() {
  rm -rf /opt/freeplane*
  rm /bin/freeplane
  rm /usr/share/applications/freeplane.desktop
}

instala_freeplane() {
   echo -e "\n\e[01;38;5;202mDescargando Freeplane $URL_DESCARGA\e[0m"
   curl -o /tmp/freeplane.zip $URL_DESCARGA
   unzip -d /opt /tmp/freeplane.zip 
   mv /opt/freeplane-$VERSION /opt/freeplane
   chmod +x /opt/freeplane/freeplane.sh
   ln -s /opt/freeplane/freeplane.sh /bin/freeplane
   cp /opt/freeplane/freeplane.svg /usr/share/icons/hicolor/scalable/apps/
   gtk-update-icon-cache /usr/share/icons/*
}

crea_lanzador() {
cat <<FIN> /usr/share/applications/freeplane.desktop
[Desktop Entry]
Version=1.0
Name=Freeplane
Icon=freeplane
Exec=/opt/freeplane/freeplane.sh
Terminal=false
Type=Application
MimeType=text/x-troff-mm;
Categories=Office;
GenericName=Freeplane
Comment=Herramienta para la creación de mapas mentales
Keywords=Mapas mentales; Brainstorming;
FIN
}

gracias() {
   echo -e "\n\n\e[01;38;5;202m####################################################################"
   echo -e "#                                                                  #"
   echo -e "#  Se ha instalado Freeplane en Fedora 32                          #"
   echo -e "#                                                                  #"
   echo -e "####################################################################\e[0m\n"
}

verifica_usuario
borra_anteriores
instala_freeplane
crea_lanzador
gracias
