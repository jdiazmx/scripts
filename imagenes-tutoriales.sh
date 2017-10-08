#!/bin/bash
######################################################################
#                                                                    #
# Script para el tratamiento de imágenes para tutoriales en Internet #
# este script realiza los siguientes pasos para cada imagen:         #
#                                                                    #
#     1) Respaldo de la imagen original                              #
#     2) Recorta la imagen.                                          #
#     3) Escala la imagen                                            #
#     4) Aplica marca de agua                                        #
#                                                                    #
# Uso: En la terminal ejecutar para todas las imágenes que se        #
#      encuentran en el mismo directorio del script.                 #
#                                                                    #
# Ejemplo: ./imagenes-tutoriales.sh                                  #
#                                                                    #
# jorge.diaz@gmail.com                                               #
# Licencia: GPL V3                                                   #
#                                                                    #
######################################################################

ALTO=720
ANCHO=400
X=0
Y=65
MAXIMO=1000

DIR_ORIGINALES="originales"
DIR_IMAGENES="images"
DIR_TUTORIALES="tutoriales"
DIR_TITULO_TUTORIAL="OpenBSD_instalacion"
RUTA_FINAL="$DIR_IMAGENES/$DIR_TUTORIALES/$DIR_TITULO_TUTORIAL"

MARCA_AGUA="logo.png"
ARCHIVO_HTML="paratutorial.html"

EXTENSIONES=(png PNG jpg JPG jpeg JPEG)

echo -ne "Creacion de carpetas...\n"
mkdir $DIR_ORIGINALES $DIR_IMAGENES $DIR_IMAGENES/$DIR_TUTORIALES $RUTA_FINAL

echo -ne "Se inicia el proceso de imagenes para tutoriales...\n"

for EXT in ${EXTENSIONES[@]}; do
   for IMAGEN in `ls -v *$EXT`; do 

      echo -ne "Imagen en proceso: $IMAGEN\n"

      NOMBRE_ARCHIVO="`basename ${IMAGEN%.$EXT}`"

      # Respaldo de la imagen 
      cp $IMAGEN $DIR_ORIGINALES

      # Recorte de imagen 
      convert -crop ${ALTO}x${ANCHO}+${X}+${Y} $IMAGEN ${NOMBRE_ARCHIVO}-recortado.$EXT
      rm $IMAGEN

      convert ${NOMBRE_ARCHIVO}-recortado.$EXT -resize ${MAXIMO}x${MAXIMO}\> $IMAGEN
      rm ${NOMBRE_ARCHIVO}-recortado.$EXT

      # Aplicar logotipo como marca de agua
      composite -dissolve 30% -gravity southeast $MARCA_AGUA $IMAGEN  F-${IMAGEN}
      mv F-${IMAGEN} $RUTA_FINAL
      rm $IMAGEN

      # Texto para archivo HTML
      echo -ne "<p align=\"justify\">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras malesuada lorem vitae nunc porta et vehicula odio gravida. Ut ac nibh nunc. Sed lacinia dignissim lacus, sit amet consequat risus cursus vel.</p>\n" >> $ARCHIVO_HTML
      echo -ne "<p align=\"center\"><img src=\"${RUTA_FINAL}/F-${IMAGEN}\" /><br />F-${IMAGEN}</p>\n<p>&nbsp;&nbsp;</p>\n" >> $ARCHIVO_HTML 

   done
done

rm ${RUTA_FINAL}/F-${MARCA_AGUA}

# Creación de gif animado
convert -loop 0 -page ${ALTO}x${ANCHO}+0+0 -delay 100 ${RUTA_FINAL}/*.png $DIR_TITULO_TUTORIAL.gif

echo -ne "Fin del proceso.\n\n"
