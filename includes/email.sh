sendEmails(){
    local emails=$1;
    local mailtitle=$2;    
    local mailtext=$3;
    
    mailtext+="\n\nThis is an automatic message from the server:  "$(hostname);
    for email in ${emails[@]}; do
        php -r "mail(\"$email\", \"$mailtitle\", \"$mailtext\");"
    done
}
