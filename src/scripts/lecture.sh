#!/bin/bash

function erreur {
echo -e "La syntaxe est :\n$0 <fichier_texte> | --help"
echo ""
echo "Appuyez sur :"
echo "ESPACE : lire/pause"
echo "Droite : avancer"
echo "Gauche : reculer"
echo "Haut : lire plus vite"
echo "Bas : lire moins vite"
echo "= : vitesse par défaut"
echo "f : baisser la hauteur de voix"
echo "j : augmenter la hauteur de voix"
echo "a : baisser le volume"
echo "z : augmenter le volume"
echo "0-5 : changer de voix"
echo "q : quitter"
}


if [ -p /dev/stdin ]; then
# Le script est dans un tube
	if [ $# -eq 0 ]; then
		readonly File=$(mktemp)
		while read line; do
			echo $line >> $File
		done
	else erreur ;
	fi
else
	# Le script n'est pas dans un 	tube
	[ $# -eq 1 ] && [ -e "$1" ] && readonly File="$1" || erreur ;
fi

####	Vitesse de lecture minimum, defaut, maximum et pas
readonly Speed_min="10"
readonly Speed_def="130"
readonly Speed_max="1000"
readonly Speed_pas="20"

####	Hauteur de la voix minimum, defaut, maximum et pas
readonly Pitch_min="0"
readonly Pitch_def="50"
readonly Pitch_max="99"
readonly Pitch_pas="5"

####	Volume sonore minimum, defaut, maximum et pas
readonly Amp_min="10"
readonly Amp_def="80"
readonly Amp_max="150"
readonly Amp_pas="20"

#### $Step; Pas pour le recul/avance
readonly Step="80"

#### Voix disponibles
declare -a readonly tab_Voices=(mb-fr1 mb-fr2 mb-fr3 mb-fr4 mb-fr5 mb-fr6)

#### Variables globales définies par défaut
Speed="$Speed_def"
Pitch="$Pitch_def"
Amp="$Amp_def"
Voice="${tab_Voices[0]}"

#### Augmente la variable vitesse
function Speed_inc ()
{
	((Speed+=Speed_pas))
	[ $[${Speed_max}-${Speed}] -lt "0" ] && Speed=$Speed_max
}

#### Diminue la variable vitesse
function Speed_dec ()
{
	((Speed-=Speed_pas))
	[ $[${Speed}-${Speed_min}] -lt "0" ] && Speed=$Speed_min
}

#### Augmente la variable Hauteur
function Pitch_inc ()
{
	((Pitch+=Pitch_pas))
	[ $[${Pitch_max}-${Pitch}] -lt "0" ] && Pitch=$Pitch_max
}

#### Diminue la variable Hauteur
function Pitch_dec ()
{
	((Pitch-=Pitch_pas))
	[ $[${Pitch}-${Pitch_min}] -lt "0" ] && Pitch=$Pitch_min
}

#### Augmente la variable Amplitude
function Amp_inc ()
{
	((Amp+=Amp_pas))
	[ $[${Amp_max}-${Amp}] -lt "0" ] && Amp=$Amp_max
}

#### Diminue la variable Amplitude
function Amp_dec ()
{
	((Amp-=Amp_pas))
	[ $[${Amp}-${Amp_min}] -lt "0" ] && Amp=$Amp_min
}

#### Avancer: on modifie $Pos
function forward ()
{
	lecture "0" ;
}


#### Fichier temporaire
readonly Filetemp="${File}.tmp"
 
#### Fichier temporaire secondaire
readonly Filetemp_sec="${File}.tmp.2"

#### Création du fichier temporaire
cat "${File}" | tr -s ' ' '\n' > "${Filetemp}"

readonly Chars="$(wc -m ${Filetemp} | cut -d" " -f1)"
readonly Words="$(wc -w "${File}" | cut -d" " -f1)"
readonly lword=$[$Chars/$Words]

#### Création du fichier temporaire secondaire
cp "${Filetemp}" "${Filetemp_sec}"

#### Nombre total de lignes
readonly Lines=$(wc -l "${Filetemp}" | cut -d' ' -f1)

#### Position courante du mot
Pos=$Lines

function elapsed_time ()
{
ps -p $Pid -o 'etimes=' | tr -s ' ' | cut -d' ' -f2
}

function get_status ()
{
case $(ps -p $Pid -o 'state=') in
S*)	echo TRUE ;;
T*)	echo FALSE ;;
esac
}

function lecture ()
{
	Time=$(elapsed_time)
	#### On tue espeak
	kill $Pid
	Run=FALSE
	Pos=$[$Pos-$Speed/60*$Time
+$1]
	[ $Pos -lt "0" ] && Pos=0
	[ $Pos -gt $Lines ] && Pos=$Lines
	tail -$Pos "${Filetemp}" > "${Filetemp_sec}"
	Params="-v ${Voice} -s ${Speed} -p ${Pitch} -a ${Amp} -f "${Filetemp_sec}""
	Command="espeak ${Params}"
	${Command} &
	Run=TRUE
	Pid="$(pgrep -f "$Command")"
#fi
}

function start_espeak ()
{
Params="-v ${Voice} -s ${Speed} -p ${Pitch} -a ${Amp} -f "${Filetemp}""
Command="espeak ${Params}"
${Command}&
Pid="$(pgrep -f "$Command")"
}

#### Programme principal

# On stoppe les bips

start_espeak ;

Run=$(get_status) ;

while IFS="" read -rsn1 k < /dev/tty
do
	case "$k" in
	"q") # On quitte le programme
		kill $Pid ;
		echo "Fin du programme" ;
		exit 0 ;;
	[0-5]) # On change de voix
		Voice=${tab_Voices[k]} ;
		lecture "+1" 2>/dev/null ;;
	"f") # Baisser la hauteur de voix
		Pitch_dec ;
		lecture "+0" 2>/dev/null ;;
	"j") # Augmenter la hauteur
		Pitch_inc ;
		lecture "+0" 2>/dev/null ;;
	"z")	# Augmenter le volume
		Amp_inc ;
		lecture "+0" 2>/dev/null ;;
	"a")	# Baisser le volume
		Amp_dec ;
		lecture "+0" 2>/dev/null ;;
	$'\x20')
	case $Run in
	TRUE) kill -STOP $Pid ;
	Run=FALSE ;;
	FALSE) kill -CONT $Pid ;
	Run=TRUE ;;
	esac ;;
	"=")	# On met la vitesse par défaut
		Speed=$Speed_def ;
		lecture "+0" 2>/dev/null ;;
	$'\x1b')
        read -rsn1 k < /dev/tty
        [ "$k" == "" ] && return
        [ "$k" == "[" ] && read -rsn1 k < /dev/tty
        [ "$k" == "O" ] && read -rsn1 k < /dev/tty
        case "$k" in
	A) 	# HAUT: on augmente la vitesse
		Speed_inc ;
		lecture "+5" 2>/dev/null ;;
	B)	# BAS: on diminue la vitesse
		Speed_dec ;
		lecture "+5" 2>/dev/null ;;
	C)	# Droite: on avance
		lecture "-5" 2>/dev/null ;;
	D)	# Gauche: on recule
		lecture "+5" 2>/dev/null ;;
	"") espeak "Vous avez appuyé sur ECHAP" ;;
	esac
	read -rsn4 -t .1 < /dev/tty # Try to flush out

	esac
done

rm $Filetemp
rm $Filetemp_sec
