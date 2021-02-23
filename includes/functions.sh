#!/bin/bash

getDbConfigsFromFile(){
    local currentLineNumber=0;
    while read line ;  
    do  
    currentLineNumber=$(( $currentLineNumber+1 ));
     if [[ -n $line ]]
     then
        sitename=`awk '{print $2}' <<< "$line"`;
        if [ "$sitename" = "$domain" ]
        then
           db_user_string=`echo "$(( $currentLineNumber+1 ))p" | ed -s "$mysql_info"`;
           db_password_string=`echo "$(( $currentLineNumber+2 ))p" | ed -s "$mysql_info"`;
           db_name_string=`echo "$(( $currentLineNumber+3 ))p" | ed -s "$mysql_info"`;

           db_user=`awk '{print $2}' <<< "$db_user_string"`;
           db_password=`awk '{print $2}' <<< "$db_password_string"`;
           db_name=`awk '{print $2}' <<< "$db_name_string"`;
        fi
     fi
    done < "$mysql_info"
}

wpCreateConfig(){
    #Creare config for wordpress#
    wp config create --dbname=$db_name --dbuser=$db_user --dbpass=$db_password --dbhost=$db_host --path=$path_to_site;
    wp config set DISALLOW_FILE_EDIT true --raw --path=$path_to_site;
    wp config set DISALLOW_FILE_MODS true --raw --path=$path_to_site;
    wp config set FS_METHOD direct --path=$path_to_site;
    #END Creare config for wordpress#


    cp $(pwd)/files/.htaccess-for-wp $path_to_site/.htaccess;        
}

wpGenerateAdminAccess(){
    adminname=$(random_username);
    adminpass=$(random_password);
    
    #If plugin been install then generate slug for admin panel
    if [[ "${plugins[@]}" =~ "${wps-hide-login}" ]];
    then
        admin_slug=$(random_word_lowercase);
    else
        admin_slug='wp-login.php';
    fi
}

wpInstallThemeAndPlugins(){
    wp theme install $theme --activate --path=$path_to_site;
    for plugin in ${plugins[@]}; do
        wp plugin install $plugin  --activate --path=$path_to_site;
    done
}


#Delete standard content comments, posts, pages from DB
wpDatabaseCleaner(){
    wp comment delete $(wp comment list --field=ID --path=$path_to_site) --path=$path_to_site --force;
    wp post delete $(wp post list --post_type=page,post --format=ids --path=$path_to_site) --path=$path_to_site;
    wp post delete $(wp post list --post_type=page,post --post_status=trash --format=ids --path=$path_to_site) --path=$path_to_site;
    wp widget reset --all --path=$path_to_site;
}


wpDatabaseConfigurator(){
    wp option update blogdescription "" --path=$path_to_site;
    wp option update blog_public 0 --path=$path_to_site;
    wp option update permalink_structure '/%postname%' --path=$path_to_site;
}

wpPluginsConfigurator(){
    # For the plugin "wps-hide-login".
    # If his active then
    # Change slug for admin panel.
    wp plugin is-active wps-hide-login --path=$path_to_site;
    if [ $? -eq 0 ]; then
        ##NEED REWRITE FUNCTION TO 'UPDATE'
        wp option delete whl_page --path=$path_to_site;
        wp option add whl_page $admin_slug --path=$path_to_site;
    fi    
}




