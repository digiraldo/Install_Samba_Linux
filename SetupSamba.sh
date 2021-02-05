#!/bin/bash
# Autor: Di Giraldo

# Colores del terminal
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)

# Imprime una línea con color usando códigos de terminal
Print_Style() {
  printf "%s\n" "${2}$1${NORMAL}"
}

# Función para leer la entrada del usuario con un mensaje
function read_with_prompt {
  variable_name="$1"
  prompt="$2"
  default="${3-}"
  unset $variable_name
  while [[ ! -n ${!variable_name} ]]; do
    read -p "$prompt: " $variable_name < /dev/tty
    if [ ! -n "`which xargs`" ]; then
      declare -g $variable_name=$(echo "${!variable_name}" | xargs)
    fi
    declare -g $variable_name=$(echo "${!variable_name}" | head -n1 | awk '{print $1;}')
    if [[ -z ${!variable_name} ]] && [[ -n "$default" ]] ; then
      declare -g $variable_name=$default
    fi
    echo -n "$prompt : ${!variable_name} -- aceptar? (y/n)"
    read answer < /dev/tty
    if [ "$answer" == "${answer#[Yy]}" ]; then
      unset $variable_name
    else
      echo "$prompt: ${!variable_name}"
    fi
  done
}
cd ~
# Obtener la ruta del directorio de inicio y el nombre de usuario
  DirName=$(readlink -e ~)
  UserName=$(whoami)
echo "Usuario: $UserName"
echo "Directorio: $DirName"

  
  

  # Instale las dependencias necesarias para ejecutar el servidor de Minecraft en segundo plano
echo "Instalando screen, unzip, sudo, net-tools, wget..."
if [ ! -n "`which sudo`" ]; then
  apt-get update && apt-get install sudo -y
fi
sudo apt-get update
sudo apt-get install screen unzip wget -y
sudo apt-get install net-tools -y
sudo apt-get install libcurl4 -y
sudo apt-get install openssl -y
sudo apt install samba -y
sudo apt install smbclient -y

# Una vez instalado, verifica que Samba está activo y ejecutándose.
sudo systemctl status nmbd

# Crear copia de seguridad del configurador de samba
sudo cp /etc/samba/smb.conf /etc/samba/smb_backup.conf


# Crear Usuario Samba
echo "========================================================================="
echo "Creamos un usuario para Samba, Predeterminado: Admin "
Print_Style "Valores permitidos: Alfanumerico sin Espacios: " "$CYAN"
read_with_prompt NewUser "Nombre de Usuario" Admin
echo "========================================================================="

sudo useradd $NewUser

#Creando grupo Samba
sudo addgroup samba
sudo usermod $NewUser -aG samba

# Crear Usuario Samba
echo "========================================================================="
echo "Se ha creado el usuario samba: $NewUser"
Print_Style "Por Favor digite la contraseña dos veces: " "$MAGENTA"
sudo smbpasswd -a $NewUser
echo "========================================================================="

# Creando directorio Compartido de Samba en /home/usuario
#sudo chown -hR username:www-data minecraftbe
# sudo sed -i '/[samba-username]/d' /etc/samba/smb.conf
sudo sed -i '$a [samba-username]' /etc/samba/smb.conf
sudo sed -n "/[samba-username]/p" /etc/samba/smb.conf
# sudo sed -i '/comment = Samba on Ubuntu/d' /etc/samba/smb.conf
sudo sed -i '$a comment = Samba on Ubuntu' /etc/samba/smb.conf
sudo sed -n "/comment = Samba on Ubuntu/p" /etc/samba/smb.conf
# sudo sed -i '/path = dirname/d' /etc/samba/smb.conf
sudo sed -i '$a path = dirname' /etc/samba/smb.conf
sudo sed -n "/path = dirname/p" /etc/samba/smb.conf
# sudo sed -i '/read only = no/d' /etc/samba/smb.conf
sudo sed -i '$a read only = no' /etc/samba/smb.conf
sudo sed -n "/read only = no/p" /etc/samba/smb.conf
# sudo sed -i '/browsable = yes/d' /etc/samba/smb.conf
sudo sed -i '$a browsable = yes' /etc/samba/smb.conf
sudo sed -n "/browsable = yes/p" /etc/samba/smb.conf
sleep 3s

# Cambia datos en smb.conf
echo "========================================================================="
echo "Agregando directorio y Usuario en Samba: $DirName - $UserName"
  sudo sed -i "s:username:$UserName:g" /etc/samba/smb.conf
  sudo sed -i "s:dirname:$DirName:g" /etc/samba/smb.conf
echo "========================================================================="


# Reiniciando Samba
sudo systemctl restart smbd.service


# Ver la ip del equipo
Print_Style "Dirección IP del Servidor..." "$RED"
hostname -I
sleep 1s

# Digitar la ip del equipo
echo "========================================================================="
Print_Style "Introduzca la IP - IPV4 del servidor: " "$MAGENTA"
read_with_prompt IPV4 "Url o dirección IP del servidor"
echo "========================================================================="

Print_Style "Configurando Ingreso a directorios desde Windows $IPV4 Usuario: $NewUser" "$YELLOW"
# Estableciendo conexión
sudo smbclient //$IPV4 /share_name –U $NewUser
Print_Style "Estableciendo conexión: smbclient //$IPV4 /share_name –U $NewUser" "$MAGENTA"

#Usuarios Samba
sudo pdbedit -L
