#!/bin/bash

## Uso: ./Acceso_PR_autossh
## Si el script falla, borar todos los archivos "script_returning_passXXXXXX" 
## en los que tengas permisos, ya que contienen tus contraseñas (tiene permisos -rwx------)


## funcion de limpieza
borrar_temp() { 
    rm -f ${SSH_ASKPASS_SCRIPT}; unset SSH_ASKPASS; passwdPR=''
    rm -f ${SSH_ASKPASS_SCRIPT_2}; unset SSH_ASKPASS_2; passwd='';
    unset DISPLAY
}



## Menu
clear
echo "Nombre del servidor - $(hostname)"
echo "------------------------------------"
echo "  Recopilacion del Reinicio en PR"
echo "------------------------------------"
echo "1. Piloto"
echo "2. Produccion 0"
echo "3. Impares"
echo "4. Pares"
echo "5. CX"
echo "6. Error BD"
echo "7. Exit"

read -p "Seleccione un grupo de máquinas: " choice

script=Busqueda_script.sh
Info='Resultados de la busqueda'

case $choice in
    1)
        HostPR="lpsrp301 lpsrp302"
        ficheroSalida="resultados_piloto_$(date +'%Y_%m_%d').txt"
        grupo='Piloto'
        ;;
    2) 
        HostPR="lppxp301 lppxp302"
        ficheroSalida="resultados_produccion0_$(date +'%Y_%m_%d').txt"
        grupo='Produccion 0'
        ;;
    3)
        HostPR="lpsro301 lpsrn301 lpsrm301 lpsri301 
        lpsrv301 lpsrv303 lpsrv305 lpsrv307 lpsrv309 
        lpsrv311 lpsrv313 lpsgl301 LPSRG301 lpevn301 
        lpevn303 lpmqr301 lppxb301 lppxb303 lppxo301 
        lppxo303 lppxo305 lppxr301 lpsrl301 lpsrv317"
        ficheroSalida="resultados_impares_$(date +'%Y_%m_%d').txt"
        grupo='Impares'
        ;;
    4)
        HostPR="lpsro302 lpsrn302 lpsrm302 lpsri302 lpsrv302 
        lpsrv304 lpsrv306 lpsrv308 lpsrv310 lpsrv312 lpsrv314 
        lpsgl302 lpevn302 lpevn304 lpmqr302 lppxb302 lppxo301 
        lppxo302 lppxo304 lppxr302 lpsrg302 lpsrl302 lpsrv318"
        ficheroSalida="resultados_pares_$(date +'%Y_%m_%d').txt"
        grupo='Pares'
        ;;
    5)
        HostPR="LGSRV401 LGSRV402"
        ficheroSalida="resultados_CX_$(date +'%Y_%m_%d').txt"
        grupo='CX'
        ;;
    6)
        HostPR="lpsrp301 lpsrp302 lppxp301 lppxp302 lpsro301 
        lpsro302 lpsrn301 lpsrn302 lpsrm301 lpsrm302 lpsri301 
        lpsri302 lpsrv301 lpsrv302 lpsrv303 lpsrv304 lpsrv305 
        lpsrv306 lpsrv307 lpsrv308 lpsrv309 lpsrv310 lpsrv311 
        lpsrv312 lpsrv313 lpsrv314 lpsgl301 lpsgl302 LPSRG301 
        lpevn301 lpevn302 lpevn303 lpevn304 lpmqr301 lpmqr302 
        lppxb301 lppxb302 lppxb303 lppxo301 lppxo302 lppxo303 
        lppxo304 lppxo305 lppxr301 lppxr302 lpsrg302 lpsrl301 
        lpsrl302 lpsrv317 lpsrv318"
        ficheroSalida="resultados_errorBD_$(date +'%Y_%m_%d').txt"
        script=Busqueda_script_errorBD.sh
        Info='Errores al cargar la base de datos:'
        ;;
    *)
        echo 'Saliendo del script...'; echo;
        exit 255;
        ;;
esac




## LogLevel error is to suppress the hosts warning. The others are
## necessary if working with development servers with self-signed
## certificates.
SSH_OPTIONS="-oLogLevel=error"
SSH_OPTIONS="${SSH_OPTIONS} -oStrictHostKeyChecking=no"
SSH_OPTIONS="${SSH_OPTIONS} -oUserKnownHostsFile=/dev/null"
SSH_OPTIONS="${SSH_OPTIONS} -o ConnectTimeout=5"


## Read Pasword from promt
## save original terminal setting.
stty_orig=`stty -g`
stty -echo
## read the password
if [[ ${HostPR[@]} =~ LGSRV40* ]]; then
    read -p "Contraseña corporativa: " passwd
    echo
    SSH_ASKPASS_SCRIPT="$(pwd)/script_returning_passCX_$(< /dev/urandom tr -dc 'a-zA-Z0-9' | head -c9)"
else
    read -p "Contraseña Temporal de PR: " passwd
    echo
    SSH_ASKPASS_SCRIPT="$(pwd)/script_returning_passPR_$(< /dev/urandom tr -dc 'a-zA-Z0-9' | head -c9)"
fi
## restore terminal setting.
stty $stty_orig

# ## Tell SSH to read in the output of the provided script as the password.
# ## We still have to use setsid to eliminate access to a terminal and thus avoid
# ## it ignoring this and asking for a password.
# SSH_ASKPASS_SCRIPT="$(pwd)/script_returning_passPR_$(< /dev/urandom tr -dc 'a-zA-Z0-9' | head -c9)"
# SSH_ASKPASS_SCRIPT="$(pwd)/script_returning_passCX_$(< /dev/urandom tr -dc 'a-zA-Z0-9' | head -c9)"


# ## Create a temp script to echo the SSH password, used by SSH_ASKPASS
# echo "echo $passwdPR" > ${SSH_ASKPASS_SCRIPT}
# chmod 700 ${SSH_ASKPASS_SCRIPT}
# echo "echo $passwd" > ${SSH_ASKPASS_SCRIPT_2}
# chmod 700 ${SSH_ASKPASS_SCRIPT_2}

echo "echo $passwd" > ${SSH_ASKPASS_SCRIPT}
chmod 700 ${SSH_ASKPASS_SCRIPT}

## Tell SSH to read in the output of the provided script as the password.
## We still have to use setsid to eliminate access to a terminal and thus avoid
## it ignoring this and asking for a password.
export SSH_ASKPASS=${SSH_ASKPASS_SCRIPT}

# Set no display, necessary for ssh to play nice with setsid and SSH_ASKPASS.
export DISPLAY=dummydisplay:0


# login="$(id -u -n)"
login=$(whoami)

# printf '#%.0s' {1..40}; printf '%s' " $Info ";printf '#%.0s' {1..40};echo ''
# grep -inH "$YYYY-$MM-$dia" ksj*.sis* | grep "$errorBD" 
# printf '#%.0s' {1..100}; echo ''
for host in $HostPR; do
    echo "Buscando en $host ...."
    setsid ssh $SSH_OPTIONS $login@$host "bash -s" < ./$script >> $ficheroSalida
    echo ; printf '#%.0s' {1..110}; echo
done

# export SSH_ASKPASS=${SSH_ASKPASS_SCRIPT_2}
# for host in $HostPR2; do
    # echo "Buscando en $host ...."
    # setsid ssh $SSH_OPTIONS $login@$host "bash -s" < ./$script >> $ficheroSalida
    # echo ; printf '#%.0s' {1..110}; echo
# done


# ## Menu para elegir mostrar los errores de la DB por pantalla
# read -t 10 -p"¿Ver errores al cargar la Base de Datos? ([Sí] o No) " choice
# if [[ $? == 0 ]];then
    # choice=${choice:-Sí}
# fi
# echo ''
# case $choice in
    # [sS][iIíÍ]|[sS])
        # echo '\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/'
        # awk '/ Errores al cargar la base de datos: /,/^#*$/ { print }' resultados_$(date +'%Y_%m_%d').txt
        # echo '\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/'
        # # exit 0
        # ;;
    # [nN][oO]|[nN]) 
        # # exit 0
        # ;;
    # *)
        # echo "Opción invalida o timeout, asumiendo No"	
        # ;;
# esac
# echo ''


borrar_temp

