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
read SERVER

echo
echo "Informe o caminho dos arquivos (Ex: /var/www/meusite.com.br ou /var/www/test.local)"
read PATH

sudo mkdir -p "$PATH"
sudo chown -R "$USER:$USER $PATH"

#permissão para o diretório web
sudo chmod -R 755 "$PATH"

#cria um arquivo index
touch "$PATH/index.php"

#phpinfo
echo '<?php phpinfo();' > "$PATH/index.php"

#cria o virtualhost
echo "Criando virtualhost para $SERVER"
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/$SERVER.conf

echo "
<Directory $PATH>
	Options Indexes FollowSymLinks MultiViews
	AllowOverride All
	Order allow,deny
	allow from all
</Directory>
<VirtualHost *:80>
	ServerAdmin webmaster@localhost
	ServerName $SERVER
	ServerAlias www.$SERVER
	DocumentRoot $PATH
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" | sudo tee /etc/apache2/sites-available/$SERVER.conf

#Ativa os novos arquivos de virtual host
echo "Ativando virtual host de test.local"
sudo a2ensite $SERVER.conf

#restart o apache novamente
echo "Reiniciando apache2"
sudo service apache2 restart

#Atualiza o arquivo hosts
echo "Atualizando arquivo hosts"
echo "127.0.1.1   $SERVER www.$SERVER" | sudo tee --append /etc/hosts
