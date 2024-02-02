# ﻿#!/bin/sh
# VERSION 1.0
# AUTHOR  Jean-Yves ROCHER
# Modifications : ACIAH et Pierre Estrem, décembre 2022
# NAME : Lire et obtenir le texte
# DESCRIPTION : Script permettant la lecture en direct de fichiers images jpg, png, tif, pdf, doc, docx et html. Le script donne aussi le texte en .txt dans le dossier d'origine.
# DEPENDANCES : le script nécessite les paquets pdftoppm, tesseract, pdftotext, unoconv.
# il faut créer le répertoire Machine-a-lire dans $HOME .
# COMPLEMENTS : le script fait appel à des fichiers sonores placés dans le dossier : /usr/local/share/advl :  frapper.pdf, patientez.pdf, FrappezF5.pdf, terminer.pdf.
# Le script fait aussi appel au script conv-txt.sh qui se trouve dans /home/aciah/.config/caja/scripts qui est appelé par le raccourci F5.
# RACCOURCIS : le script A-lire-et-obtenir-le-texte se trouve dans /home/aciah/.config/caja/scripts et est appelé par le raccourci F8. Les deux raccourcis sont à définir dans /home/aciah/.config/caja/accels
# LECTURE : la lecture se fait avec le script lecture.sh qui se trouve dans /usr/bin/. Avec la flèche-bas on diminue le rythme de lecture. Avec la flèche-haut on augmente le rythme de lecture.

# Décommenter les deux lignes suivantes pour récupérer les log du script et les afficher en direct dans un terminal
# exec 1>>/var/log/aciah/lireALaVolee.log 2>>/var/log/aciah/lireALaVolee.log
# xterm -e "tail -f /var/log/aciah/lireALaVolee.log" &

 FICHIER=`basename $1`
 FILE=`basename ${FICHIER%.*}`
 CHEMIN=`dirname $1`
 REPLECTURE="$HOME"/Machine-a-lire
 TYPE=`mimetype -i -b $1`
aplay /usr/local/share/advl/beep.wav  # petit bruit

pdftotext -layout /usr/local/share/advl/frappez.pdf - | espeak -a 200 -v mb-fr1 -s 130  #rappelle qu'il faut frapper la touche Q à la fin de la lecture.
# on coupe la voix Orca, il ne faudra pas oublier de la relancer.
if pgrep "orca" > /dev/null; then
        killall orca &
        sleep 2
        killall -9 speech-dispatcher &
fi

######### Fichier de type PDF   ######### 
 if [ ! -z "`echo "$TYPE" | grep -i 'pdf' `" ]; then
         pdftoppm -r 200 -tiff "$CHEMIN"/"$FICHIER" "$REPLECTURE"/alavolee
             for alavolee in "$REPLECTURE"/*.tif; do
tesseract "$alavolee" repf

x-terminal-emulator -e /usr/bin/lecture.sh repf.txt
             done
mv repf.txt ${FICHIER%\.*}.txt

 fi
 
########  Fichier de type PNG  #####
  if [ ! -z "`echo "$TYPE" | grep -i -e 'png' `" ]; then echo  
tesseract "$CHEMIN"/"$FICHIER" repp
x-terminal-emulator -e /usr/bin/lecture.sh repp.txt
  fi
mv repp.txt ${FICHIER%\.*}.txt

########  Fichier de type jpg  ##### 

  if [ ! -z "`echo "$TYPE" | grep -i -e 'jpeg' `" ]; then echo  
tesseract "$CHEMIN"/"$FICHIER" repj
x-terminal-emulator -e /usr/bin/lecture.sh repj.txt
  fi
mv repj.txt ${FICHIER%\.*}.txt


rm $HOME/Machine-a-lire/alavolee*
rm repf.*
rm repp.*
rm repj.*

########### Fichier odt, doc, html #############

 if [ ! -z "`echo "$TYPE" | grep -i 'doc' `" ]; then
pdftotext -layout /usr/local/share/advl/patientez.pdf - | espeak -a 200 -v mb-fr1 -s 150
fi
File="$1"
unoconv --doctype=document --format=txt "$File"
cp "${File%\.*}.txt" $HOME/Machine-a-lire/
x-terminal-emulator -e /usr/bin/lecture.sh $HOME/Machine-a-lire/"${File%\.*}.txt"
fi

if (mimetype==html); then
pdftotext -layout /usr/local/share/advl/FrappezF5.pdf - | espeak -a 200 -v mb-fr1 -s 150
fi

if [ ! -z "`echo "$TYPE" | grep -i 'odt' `" ]; then
pdftotext -layout /usr/local/share/advl/FrappezF5.pdf - | espeak -a 200 -v mb-fr1 -s 150
fi

if [ ! -z "`echo "$TYPE" | grep -i 'docx' `" ]; then
#pdftotext -layout /usr/local/share/advl/patientez.pdf - | espeak -a 200 -v mb-fr1 -s 150
fi



#pdftotext -layout /usr/local/share/advl/terminer.pdf - | espeak -a 200 -v mb-fr1 -s 150
exit
