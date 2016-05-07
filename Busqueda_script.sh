#!/bin/bash

alias grep='grep --color'
echo ''; date; hostname; echo ''
ps -U xpjboss1 -u xpjboss1 -o user,pid,lstart,cmd | awk '{print $1,$4,$5,$6,$7,$10}' | grep KSJ
ps -U xpjboss1 -u xpjboss1 -o user,pid,lstart,cmd | awk '{print $1,$4,$5,$6,$7,$10}' | grep QSRV


## Extraer día y la hora
procesos=$(ps -U xpjboss1 -u xpjboss1 -o user,pid,lstart,cmd )
procesos=$(echo -e "$procesos\n" | awk '{print $1,$4,$5,$6,$7,$10}' | grep QSRV)
dia=$(echo -e "$procesos\n" | awk '{print $3}' | cut -d$'\n' -f3)
hms=$(echo -e "$procesos\n" | awk '{print $4}' | cut -d$'\n' -f3)
hora=$(echo $hms | cut -d':' -f1)
dia=$(printf "%02d" $dia)

## Extraer varias horas
# hms=$(echo -e "$procesos\n" | awk '{print $4}')
# horas=$(echo -e "$hms\n" | cut -d':' -f1)
# Hora=$(echo $horas | cut -d' ' -f1)
# for h in $horas; do  
    # if [[ ! "${Hora[@]}" =~ "${h}" ]]; then
         # Hora="${Hora} $h"
    # fi    
# done


## Cadenas de texto a buscar
if [[ $(hostname) =~ l[i|d].* ]]; then
    Inicio='Arrancando el gestor de la configuración'
else
    Inicio='Finalizada la carga de propiedades'
fi

Fin='Terminada la carga del preproceso dentro de '
# errorBD='Error al arrancar el contexto para la conexión con la BD de catálogos'


## Expresion regular de respuesta OK al consumo
RegFin='Recibida respuesta del .* con resultado OK'

cd /logs/app; pwd
## Solo se busca en las piezas KSJW y KSJZ evidencias del inicio
## Del error de la base de datos se busca en todas las piezas
Ficheros='ksjw.sistema*.log'; Ficheros=$(echo $Ficheros)
Ficheros2='ksjz.sistema*.log'; Ficheros2=$(echo $Ficheros2)
Ficheros="$Ficheros $Ficheros2"
Ficheros=$(echo -e $Ficheros | tr " " "\n" | sed '/.*gz/d' | grep -i $(hostname))
Ficheros2=''


## Formateando busqueda por fecha
read YYYY MM DD <<< $(date +'%Y %m %d')
Tiempo="$YYYY-$MM-$dia $hora:"
Tiempo=$(echo $Tiempo | cut -d'"' -f2)


## Busqueda de errores en la carga de la BD
# printf '#%.0s' {1..36}; printf '%s' " Errores al cargar la base de datos: ";printf '#%.0s' {1..36};echo ''
# grep -inH "$YYYY-$MM-$dia" ksj*.sis* | grep "$errorBD" 
# printf '#%.0s' {1..100}; echo ''


## Busqueda del Reinicio en las piezas KSJW y KSJZ


for file in $Ficheros; do
    printf '#%.0s' {1..100}; echo ''
    # grep -inH -P "$regexTiempo" $file | sed -n "/$textInicio/,/$textoFin/p"
    # grep -nH -P "$regexTiempo" $file | awk "/$textInicio/,/$textoFin/"
    echo $file
    grep -inH "$Tiempo" $file | sed -n "/$Inicio/,/$Fin/p"
done
echo ''; printf '=%.0s' {1..110}; echo ''




echo ''; printf '#%.0s' {1..110}; echo ''
echo -e '\nFinalizada la ejecucion del script'
echo ''; printf '#%.0s' {1..110}; echo ''

