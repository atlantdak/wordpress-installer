#!/bin/bash

random_username(){
    ALL_NON_RANDOM_WORDS=$(pwd)/files/usernames_vocabulary.txt
    # total number of non-random words available 
    non_random_words=`cat $ALL_NON_RANDOM_WORDS | wc -l` 
    #Get name from vocabulary
    random_number=`od -N3 -An -i /dev/urandom | 
    awk -v f=0 -v r="$non_random_words" '{printf "%i\n", f + r * $1 / 16777216}'` 
    random_word=$(echo "$a" | sed $random_number"q;d" $ALL_NON_RANDOM_WORDS);
    #Generete random number for add a numerical ending
    count_of_numbers=$(( ( RANDOM % 5 ) ));
    if [ $count_of_numbers -gt 0 ]
    then
        #Generete numerical ending
        numerical_ending=`echo $RANDOM$RANDOM$RANDOM | cut -c1-$count_of_numbers`
    else
        numerical_ending=''
    fi

    #Random word + random numeric
    random_word=$random_word$numerical_ending;
    echo $random_word;
}

random_word_lowercase(){
    word_length=$(( ( RANDOM % 10 ) + 10 ));
    echo `cat /dev/urandom | tr -dc 'a-z' | fold -w ${1:-$word_length} | head -n 1`;
}

random_password(){
    echo `cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1`;
}

