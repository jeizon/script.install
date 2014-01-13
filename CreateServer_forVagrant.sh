#!/bin/bash
#Script para configurar ambiente drupal no vagrant
#-------------------------------------------------------------------------------------------------------------------------#

#Variaveis usadas ao longo do script
mysql_pass="Ab1234"   #Definir senha para o usuário root no mysql e do phpmyadmin
URL="teste.dev"       #Definir url do projeto (Será configurado la no vhost
DBNAME="dev_teste"    #Definir nome do bando de dados a ser criado

#-------------------------------------------------------------------------------------------------------------------------#

#Manutenção sistema
echo "\n\n"
sudo apt-get -q -y update && sudo apt-get -q -y autoremove && sudo apt-get -q -y autoclean
echo "\n\n"
  
#-------------------------------------------------------------------------------------------------------------------------#

#Instalação do MYSQL
echo "\n\nIniciando instalação do Mysql-Server\n"
echo mysql-server mysql-server/root_password password $mysql_pass | sudo debconf-set-selections
echo mysql-server mysql-server/root_password_again password $mysql_pass | sudo debconf-set-selections
sudo apt-get -q -y install mysql-server

#Configurando Senha e Configurações para Acesso Remoto
sudo cp /etc/mysql/my.cnf /etc/mysql/my.bak.cnf
sudo sed -i "47s/^/#/" /etc/mysql/my.cnf  #Comenta o bind-andress (Linha 47) para acesso remoto
mysql -uroot -p$mysql_pass -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '"$mysql_pass"'; FLUSH PRIVILEGES;" 
sudo service mysql restart
echo "\n\nInstalação do mysql esta completa\n"
echo "Criando database com o nome "$DBNAME""
mysql -uroot -p$mysql_pass -e "create database "$DBNAME";"
#-------------------------------------------------------------------------------------------------------------------------#

#Instalando o PhpMyAdmin
echo phpmyadmin phpmyadmin/dbconfig-install boolean true | sudo debconf-set-selections
echo phpmyadmin phpmyadmin/app-password-confirm password $mysql_pass | sudo debconf-set-selections
echo phpmyadmin phpmyadmin/mysql/admin-pass password $mysql_pass | sudo debconf-set-selections
echo phpmyadmin phpmyadmin/mysql/app-pass password $mysql_pass | sudo debconf-set-selections
echo phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2 | sudo debconf-set-selections
sudo apt-get install -q -y phpmyadmin
sudo service mysql restart

#-------------------------------------------------------------------------------------------------------------------------#

#Instalação de programas
echo "\n\nInstalando Git, Zip e curl\n"
sudo apt-get install -y git-core zip curl 
echo "\n\nInstalando Apache2, php5 e dependencias\n"
sudo apt-get install -y  apache2 php5 libapache2-mod-php5 php5-mysql drush
echo "\n\nInstalando bibliotecas do php5\n"
sudo apt-get install -y php5-curl php5-gd php5-idn php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl 

#-------------------------------------------------------------------------------------------------------------------------#

#Ativar re-write
sudo a2enmod rewrite

#Ativando o servername httpd (Fix mensagem de erro)
sudo sh -c 'echo "ServerName work.apache" >> /etc/apache2/httpd.conf' && sudo service apache2 restart
echo "\n\nFim da instalação do Apache2 e php5 mais bibliotecas\n"
sudo sh -c 'echo "<?php phpinfo(); ?> " >> /var/www/info.php'

#-------------------------------------------------------------------------------------------------------------------------#

#Criando vhost
#Criando pastas do projeto
sudo mkdir -p /home/vagrant/projeto/$URL/public_html/
sudo mkdir -p /home/vagrant/projeto/$URL/logs/

sudo sh -c "echo '<VirtualHost *:80>

			ServerAdmin webmaster@localhost
			ServerName localhost
			ServerAlias $URL
			DocumentRoot /home/vagrant/projeto/$URL/public_html
			ErrorLog /home/vagrant/projeto/$URL/logs/error.log
			LogLevel warn
			CustomLog /home/vagrant/projeto/$URL/logs/acess.log combined
			
</VirtualHost> ' > /etc/apache2/sites-available/$URL"

sudo sh -c 'echo "<?php echo '$URL'; ?>" >> /home/vagrant/projeto/'$URL'/public_html/index.php' 
sudo sh -c 'echo "127.0.0.1 '$URL'" >> /etc/hosts'

echo "Ativando vhost '$URL' e reiniciando apache2"
sudo a2ensite $URL && sudo service apache2 restart

#-------------------------------------------------------------------------------------------------------------------------#

#Informações Finais
echo "\n\nTodas informações: "
echo "Para acessar o site entre no navegador e digite 'localhost/ ' ou coloque no \n host do windows o site '127.0.0.1   $URL' "
echo "E acesse esse endereço $URL no seu navegador"
echo "\nO nome da base escolhido foi '$DBNAME' \nConfigure o seu settings com o banco, usuário root e a senha '$mysql_pass'\n\n"







