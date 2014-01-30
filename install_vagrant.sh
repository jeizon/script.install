#!/bin/bash
#Script para configurar ambiente drupal no vagrant
#-------------------------------------------------------------------------------------------------------------------------#

#Variaveis usadas ao longo do script
mysql_pass="password"   #Definindo senha para o usuário root no mysql e do phpmyadmin
URL="folder_name"
SERVERNAMES="URL"
DBNAME="base_name1"
DBNAME2="base_name2"

#-------------------------------------------------------------------------------------------------------------------------#

#Manutenção sistema
echo ""
sudo apt-get -q -y update && sudo apt-get -q -y autoremove && sudo apt-get -q -y autoclean
echo ""
  
#-------------------------------------------------------------------------------------------------------------------------#

#Instalação do MYSQL
echo "###########################################"
echo "#   Iniciando instalacao do Mysql-Server  #"
echo "###########################################"
echo ""
echo mysql-server mysql-server/root_password password $mysql_pass | sudo debconf-set-selections
echo mysql-server mysql-server/root_password_again password $mysql_pass | sudo debconf-set-selections
sudo apt-get -q -y install mysql-server

#Configurando Senha e Configurações para Acesso Remoto
sudo cp /etc/mysql/my.cnf /etc/mysql/my.bak.cnf
sudo sed -i "47s/^/#/" /etc/mysql/my.cnf  #Comenta o bind-andress (Linha 47) para acesso remoto
mysql -uroot -p$mysql_pass -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '"$mysql_pass"'; FLUSH PRIVILEGES;" 
sudo service mysql restart

echo "###########################################"
echo "#   Instalacao do mysql esta completa     #"
echo "###########################################"
echo ""


echo "########################"
echo "#  Criando database    #"
echo "########################"
echo ""

mysql -uroot -p$mysql_pass -e "SET GLOBAL max_allowed_packet=128*1024*1024;"
mysql -uroot -p$mysql_pass -e "SET GLOBAL key_buffer_size=1*1024*1024*1024;"
mysql -uroot -p$mysql_pass -e "SET GLOBAL sort_buffer_size=128*1024*1024;"
mysql -uroot -p$mysql_pass -e "SET GLOBAL read_buffer_size=128*1024*1024"

#if mysql -uroot -p$mysql_pass -e "create database "$DBNAME"" -eq 1; then
mysql -uroot -p$mysql_pass -e "create database "$DBNAME";"
mysql -uroot -p$mysql_pass $DBNAME < /home/vagrant/projetos/Itelios.GilbertGaillard.Site/$DBNAME.mysql
 # fi
#if mysql -uroot -p$mysql_pass -e "create database "$DBNAME2"" -eq 1; then
mysql -uroot -p$mysql_pass -e "create database "$DBNAME2";"
mysql -uroot -p$mysql_pass $DBNAME2 < /home/vagrant/projetos/Itelios.GilbertGaillard.Site/$DBNAME2.mysql
  #fi

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
echo "###########################################"
echo "#   Instalando Git, Zip e curl            #"
echo "###########################################"
echo ""
sudo apt-get install -y git-core zip curl make
echo "###########################################"
echo "# Instalando Apache2, php5 e dependencias #"
echo "###########################################"
echo ""
apt-cache search php-apc
sudo apt-get install -y  apache2 php5 libapache2-mod-php5 php5-mysql php-apc
echo "###########################################"
echo "#     Instalando bibliotecas do php5      #"
echo "###########################################"
echo ""
sudo apt-get install -y php5-curl php5-gd php5-idn php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl 

#-------------------------------------------------------------------------------------------------------------------------#

#Ativar re-write
sudo a2enmod rewrite

#Ativando o servername localhost (Fix mensagem de erro)
sudo sh -c 'echo "ServerName localhost" >> /etc/apache2/httpd.conf' && sudo service apache2 restart
echo "########################################################"
echo "# Fim da instalacao do Apache2 e php5 mais bibliotecas #"
echo "########################################################"
echo ""
sudo sh -c 'echo "<?php phpinfo(); ?> " >> /var/www/info.php'

#-------------------------------------------------------------------------------------------------------------------------#
#Criando vhost

#Criando pastas do projetos

sudo mkdir -p /home/vagrant/projetos/$URL/
sudo mkdir -p /home/vagrant/projetos/$URL/logs/

sudo sh -c "echo '<VirtualHost *:80>

	ServerAdmin webmaster@localhost
	ServerName $SERVERNAMES
	ServerAlias $URL
	DocumentRoot /home/vagrant/projetos/$URL/
	ErrorLog /home/vagrant/projetos/$URL/logs/error.log
		LogLevel error
	CustomLog /home/vagrant/projetos/$URL/logs/acess.log combined

</VirtualHost> ' > /etc/apache2/sites-available/$URL"

# sudo sh -c 'echo "<?php echo '$URL'; ?>" >> /home/vagrant/projetos/'$URL'/public_html/index.php' 
sudo sh -c 'echo "127.0.0.1 '$URL'" >> /etc/hosts'

echo "########################################################"
echo "#      Ativando vhost '$URL' e reiniciando apache2     #"
echo "########################################################"
echo ""
sudo a2ensite $URL && sudo /etc/init.d/apache2 restart

#-------------------------------------------------------------------------------------------------------------------------#








