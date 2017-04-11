#!/bin/sh

###############################################################################
# Instalación de Mozilla Firefox Developer Edition y Nightly Edition          #
#                                                                             #
# Para actualizar será necesario ejecutar nuevamente el script.               #
#                                                                             #
# Basado en el script de Rob Thijssen - git.io/firefoxdev		      #
#  de https://gist.github.com/grenade/                                        #
# Logo Firefox en ASCII de Srikanth Agaram                                    #
#                                                                             #
# Autor: Jorge Antonio Díaz Lara - jorge.diaz@gmail.com                       #
#                                  jorge@integraci.com.mx                     #    
#                                                                             #
###############################################################################

# Variables Firefox Developer Edition
INICIA_FFD="ffd"
DIRECTORIO_INSTALACION_FFD="/opt/firefox-developer-edition"

# Variables Firefox Nightly
INICIA_FFN="ffn"
DIRECTORIO_INSTALACION_FFN="/opt/firefox-nightly"

# Detección de la arquitectura del sistema usando el comando "uname -m"
if [ "$(uname -m)" = "x86_64" ]; then
  ARQUITECTURA="x86_64"
else
  ARQUITECTURA="i686"
fi

# Detección del idioma del sistema desde la variable "LANG" del sistema
IDIOMA=$(echo $LANG | sed -r 's/([a-z]{2})_([A-Z]{2}).*/\1-\2/')

###############################################################################
# Funciones
###############################################################################
instala_firefox_developer_edition() {
   # Descarga e instalación de Firefox Developer Edition
   echo -e "\n\e[01;38;5;202mDescargando Mozilla Firefox Developer Edition:\e[0m \e[1;97m${BUILD_FFD}\e[0m"
   curl -o $HOME/$INICIA_FFD.tar.bz2 $URL_FFD

   if tar -xf $HOME/$INICIA_FFD.tar.bz2 --directory=$HOME; then

      # Crea el archivo para lanzar la aplicación basado en el de Firefox
      cat /usr/share/applications/firefox.desktop | sed -r 's/Name=Firefox/Name=Firefox Developer Edition/g' | sed -r 's/Exec=firefox %u/Exec=ffd %u/g' | sed -r "s/Icon=firefox/Icon=$(echo $DIRECTORIO_INSTALACION_FFD | sed -r 's/\//\\\//g')\/browser\/chrome\/icons\/default\/default48.png/g" > $HOME/firefox/$INICIA_FFD.desktop

      # Borra el directorio de instalación y el enlace simbólico en caso de que existan
      rm -rf $DIRECTORIO_INSTALACION_FFD /bin/$INICIA_FFD

      # Añade la Firefox Developer Edition a la lista de aplicaciones
      rm -rf /usr/share/applications/$INICIA_FFD.desktop
      ln -s $DIRECTORIO_INSTALACION_FFD/$INICIA_FFD.desktop /usr/share/applications/$INICIA_FFD.desktop

      mv $HOME/firefox $DIRECTORIO_INSTALACION_FFD
      ln -s $DIRECTORIO_INSTALACION_FFD/firefox /bin/$INICIA_FFD
  
      rm $HOME/$INICIA_FFD.tar.bz2
   fi
}

instala_firefox_nightly() {
   # Descarga e instalación de Firefox Nightly
   echo -e "\n\e[01;38;5;202mDescargando Mozilla Firefox Nightly:\e[0m \e[1;97m${BUILD_FFN}\e[0m"
   curl -o $HOME/$INICIA_FFN.tar.bz2 $URL_FFN

   if tar -xf $HOME/$INICIA_FFN.tar.bz2 --directory=$HOME; then

      # Crea el archivo para lanzar la aplicación basado en el de Firefox
      cat /usr/share/applications/firefox.desktop | sed -r 's/Name=Firefox/Name=Firefox Nightly/g' | sed -r 's/Exec=firefox %u/Exec=ffn %u/g' | sed -r "s/Icon=firefox/Icon=$(echo $DIRECTORIO_INSTALACION_FFN | sed -r 's/\//\\\//g')\/browser\/chrome\/icons\/default\/default48.png/g" > $HOME/firefox/$INICIA_FFN.desktop

      # Borra el directorio de instalación y el enlace simbólico en caso de que existan
      rm -rf $DIRECTORIO_INSTALACION_FFN /bin/$INICIA_FFN
  
      # Añade Firefox Nightly a la lista de aplicaciones
      rm -rf /usr/share/applications/$INICIA_FFN.desktop
      ln -s $DIRECTORIO_INSTALACION_FFN/$INICIA_FFN.desktop /usr/share/applications/$INICIA_FFN.desktop

      mv $HOME/firefox $DIRECTORIO_INSTALACION_FFN
      ln -s $DIRECTORIO_INSTALACION_FFN/firefox /bin/$INICIA_FFN
  
      rm $HOME/$INICIA_FFN.tar.bz2
   fi
}

gracias() {
   echo -e "\n\n\e[01;38;5;202m################################################################################"
   #echo -e "\n\n\e[1;37;44m################################################################################"
   echo -e "#                        __                                                    #"
   echo -e "#                   _--'\"  \"\0140--_                                               #"
   echo -e "#           /( _--'_.        =\":-_                                             #"
   echo -e "#           | \___/{          '>_ \".       Gracias por usar este script        #"
   echo -e "#           |-\"  ' /\            :  \:                                         #"
   echo -e "#          /       { \0140-_*         \  |                                         #"
   echo -e "#         '/        -:='           |  \:                                       #"
   echo -e "#         {   '  -___\            |/   |                                       #"
   echo -e "#        |   :   / (.             |     /  \"Comunidad Mozilla México\"          #"
   echo -e "#        \0140.   .  | | \_-'-.     )\|    '                                       #"
   echo -e "#         |    :  \` \ __-'-    /      |                                        #"
   echo -e "#          \    ".   "'--__-''\"         /                                          #"
   echo -e "#           \     "--"''   ,.'\":     /                                           #"
   echo -e "#     -AKS   \`-_        ''" .."   _-'                                            #" 
   echo -e "#               \"'--__      __--'\"         Visita: http://mozilla-mexico.org   #"
   echo -e "#                      \"\"--\"\"              contacto@mozilla-mexico.org         #"
   echo -e "#                                                                              #"
   echo -e "################################################################################\e[0m\n"
}

###############################################################################

# Verificar que el usuario tenga permisos de administrador
if [[ $EUID -ne 0 ]]; then
   echo -e "\n\e[1;38;5;202mPara instalar Mozilla Firefox Developer Edition y Firefox Nightly\nes necesario que tengas permisos de administrador.\n"
   exit 1
fi

# Despliega en pantalla la información del sistema
echo -e "\n\n\e[1;3;4;97mDATOS DE TU SISTEMA\e[0m"
echo -e "\e[0;37mArquitectura: \e[1;97m$ARQUITECTURA\e[0m"
echo -e "\e[0;37mIdioma:       \e[1;97m$IDIOMA\e[0m"

# Detección de la última version Firefox Developer Edition usando "echo, curl y sed" 
BUILD_FFD=$(echo $(curl -s https://download-installer.cdn.mozilla.net/pub/firefox/nightly/latest-mozilla-aurora-l10n/linux-$ARQUITECTURA/xpi/) | sed -r "s/.*firefox-([0-9\.a]+)\.$IDIOMA\.langpack\.xpi.*/\1/")
URL_FFD="https://download-installer.cdn.mozilla.net/pub/firefox/nightly/latest-mozilla-aurora-l10n/firefox-$BUILD_FFD.$IDIOMA.linux-$ARQUITECTURA.tar.bz2"

# Detección de instalación previa de Mozilla Firefox Developer Edition
if [ -e /bin/$INICIA_FFD ]; then
   INSTALADO_FFD=$($INICIA_FFD -v | sed -r "s/Mozilla Firefox //")
   if [ "$BUILD_FFD" == "$INSTALADO_FFD" ]; then
      echo -e "\n\e[0;37mSe encuentra actualizado Mozilla Firefox Developer Edition. Versión $INSTALADO_FFD\e[0m"
   else
      echo -e "\n\e[0;37mSe encuentra instalado la versión \e[1;97m$INSTALADO_FFD \e[0;37mde Mozilla Firefox Developer Edition\e[0m"
      echo -e "\e[0;37mActualizando a la versión:\e[0m \e[1;97m$BUILD_FFD.\e[0m"
      instala_firefox_developer_edition
      echo -e "\n\e[1;93mFirefox Developer Edition se ha actualizado correctamente!\e[0m"
      echo -e "\e[0;37mInicia con: $INICIA_FFD\e[0m\n"
   fi
else
   echo -e "\nNo se encuentra instalado Mozilla Firefox Developer Edition, se procede con la instalación de la versión $BUILD_FFD."
   instala_firefox_developer_edition
   echo -e "\n\e[1;93mFirefox Developer Edition se ha instalado correctamente!\e[0m"
   echo -e "\e[0;37mInicia con: $INICIA_FFD\e[0m\n"
fi

# Detección de la última versión de Firefox Nightly
BUILD_FFN=$(echo $(curl -s https://download-installer.cdn.mozilla.net/pub/firefox/nightly/latest-mozilla-central-l10n/linux-$ARQUITECTURA/xpi/) | sed -r "s/.*firefox-([0-9\.a]+)\.$IDIOMA\.langpack\.xpi.*/\1/")
URL_FFN="https://download-installer.cdn.mozilla.net/pub/firefox/nightly/latest-mozilla-central-l10n/firefox-$BUILD_FFN.$IDIOMA.linux-$ARQUITECTURA.tar.bz2"

# Detección de instalación previa de Mozilla Firefox Nightly
if [ -e /bin/$INICIA_FFN ]; then
   INSTALADO_FFN=$($INICIA_FFN -v | sed -r "s/Mozilla Firefox //")
   if [ "$BUILD_FFN" == "$INSTALADO_FFN" ]; then
      echo -e "\n\e[0;37mSe encuentra actualizado Mozilla Firefox Nightly. Versión $INSTALADO_FFN"
   else
      echo -e "\n\e[0;37mSe encuentra instalado la versión \e[1;97m$INSTALADO_FFN \e[0;37mde Mozilla Firefox Nightly"
      echo -e "\e[0;37mActualizando a versión:\e[0m \e[1;97m$BUILD_FFN"
      instala_firefox_nightly

      echo -e "\n\e[1;93mFirefox Nightly \e[1;97m$BUILD_FFN \e[1;93mse ha actualizado correctamente!\e[0m"
      echo -e "\e[0;37mInicia con: $INICIA_FFN\e[0m\n"
   fi
else
   echo -e "\nNo se encuentra instalado Mozilla Firefox Nightly, se procede con la instalación de la versión $BUILD_FFN."
   instala_firefox_nightly
   echo -e "\n\e[1;93mFirefox Nightly $BUILD_FFN se ha instalado correctamente!\e[0m"
   echo -e "\e[0;37mInicia con: $INICIA_FFN\e[0m\n"
fi

gracias
