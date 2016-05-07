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

## Extraer varias horas
hms=$(echo -e "$procesos\n" | awk '{print $4}')
horas=$(echo -e "$hms\n" | cut -d':' -f1)
Hora=$(echo $horas | cut -d' ' -f1)
for h in $horas; do  
    if [[ ! "${Hora[@]}" =~ "${h}" ]]; then
        # whatever you want to do when arr contains value
         Hora="${Hora} $h"
    # else
        # # whatever you want to do when arr doesn't contain value
    fi    
done


errorBD='Error al arrancar el contexto para la conexión con la BD de catálogos'



## Formateando busqueda por fecha
read YYYY MM DD <<< $(date +'%Y %m %d')
# Tiempo="$YYYY-$MM-$dia $hora:"
# Tiempo=$(echo $Tiempo | cut -d'"' -f2)


cd /logs/app; pwd

Ficheros='ksj*.sistema*.log'; Ficheros=$(echo $Ficheros)
Ficheros=$(echo -e $Ficheros | tr " " "\n" | sed '/.*gz/d' | grep -i $(hostname))

## Busqueda de errores en la carga de la BD
printf '#%.0s' {1..36}; printf '%s' " Errores al cargar la base de datos: ";printf '#%.0s' {1..36};echo ''
# grep -inH "$YYYY-$MM-$dia" ksj*.sis*.log | grep "$errorBD" 
# printf '#%.0s' {1..100}; echo ''

for file in $Ficheros; do
    printf '#%.0s' {1..100}; echo ''
    echo $file
    grep -inH "$YYYY-$MM-$DD" $file | grep "$errorBD" 
done
echo ''; printf '=%.0s' {1..100}; echo ''



echo ''; printf '#%.0s' {1..110}; echo ''
echo -e '\nFinalizada la ejecucion del script'
echo ''; printf '#%.0s' {1..110}; echo ''

