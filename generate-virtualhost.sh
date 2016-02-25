#!/bin/bash
#
# Gerador de virtual host no apache
# Por: Douglas Cabral
# Data: 25/02/2016
#

sudo -v

# Keep-alive: update existing sudo time stamp if set, otherwise do nothing.
#see https://gist.github.com/cowboy/3118588
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo
echo "Informe o nome do server (Ex: meusite.com.br ou test.local)"
read -r MYSERVER

echo
echo "Informe o caminho dos arquivos (Ex: /var/www/meusite.com.br ou /var/www/test.local)"
read -r MYPATH

sudo mkdir -p "$MYPATH"
sudo chown -R "$USER":"$USER" "$MYPATH"

#permissão para o diretório web
sudo chmod -R 755 "$MYPATH"

#cria um arquivo index
touch "$MYPATH"/index.php

#phpinfo
echo '<?php phpinfo();' > "$MYPATH"/index.php

#cria o virtualhost
echo "Criando virtualhost para $MYSERVER"
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/"$MYSERVER".conf

echo "
<Directory $MYPATH>
	Options Indexes FollowSymLinks MultiViews
	AllowOverride All
	Order allow,deny
	allow from all
</Directory>
<VirtualHost *:80>
	ServerAdmin webmaster@localhost
	ServerName $MYSERVER
	ServerAlias www.$MYSERVER
	DocumentRoot $MYPATH
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" | sudo tee /etc/apache2/sites-available/"$MYSERVER".conf

#Ativa os novos arquivos de virtual host
echo "Ativando virtual host de test.local"
sudo a2ensite "$MYSERVER".conf

#restart o apache novamente
echo "Reiniciando apache2"
sudo service apache2 restart

#Atualiza o arquivo hosts
echo "Atualizando arquivo hosts"
echo "127.0.1.1   $MYSERVER www.$MYSERVER" | sudo tee --append /etc/hosts
