#!/bin/bash


#======= Includes system files for script
. config.sh
. includes/random-word-generator.sh
. includes/functions.sh
. includes/email.sh
#====== 
domains=("domain.com" "example.com");

# Absolute path to local .zip archive with theme or theme slug from wordpress.org
theme=("twentytwentyone");
# Path to local .zip archive with plugin or plugin slug from wordpress.org
plugins=("wps-hide-login" "wordpress-seo" "classic-editor");
# Wordpress lacale
locale="en_US";
# Wordpress core version
wpversion="5.5.3";
# if website will be with www. then put www. to gap below
wwwSubdomainWithDot=""; # @wwwSubdomainWithDot='www.' or @wwwSubdomainWithDot=''




###First part script###
for domain in ${domains[@]}; do
    export path_to_site="$path_to_www/$domain/$site_subdir";
    #Проверяю существует ли данный каталог, если не существует, тогда пропускаю шаг цикла и пишу что домен не найден
    if [ ! -d "$path_to_site" ]
    then
        echo "Domain $domain not found";
        continue
    fi

    #Download core
    wp core download --version=$wpversion --locale=$locale --path=$path_to_site --skip-content;
    
    #Get config access data for database from file
    getDbConfigsFromFile;

    #Function for create config file
    wpCreateConfig;

    #Generate variables for admin panel access: @adminname, @adminpass, @admin_slug
    wpGenerateAdminAccess;
    
    #Install core
    wp core install --url=$wwwSubdomainWithDot$domain --title=$domain --admin_user=$adminname --admin_email=$adminname@$domain --admin_password=$adminpass --skip-email --path=$path_to_site;

    #Install the necessary plugins and theme
    wpInstallThemeAndPlugins;

    #Delete standard content comments, posts, pages from DB
    wpDatabaseCleaner;

    #Admin Panel configurator (set fields in options.php)
    wpDatabaseConfigurator;

    #Configure installed plugins
    wpPluginsConfigurator;
    
    #Generate text with access to sites for email notify
    mailtext+="http://$domain/$admin_slug\n$adminname\n$adminpass\n\n\n";

done


echo 'Access for created Wordpress sites' $mailtext;

#Sending a letter with access to sites
sendEmails $emails 'Access for created Wordpress sites' $mailtext;



