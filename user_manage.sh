#!/bin/bash

# Function to generate a random password
generate_password() {
    local length=4
    local lower='abcdefghijklmnopqrstuvwxyz'
    local upper='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    local digits='0123456789'
    local special='!@#$%^&*()-=_+[]{}|;:.<>?'

    # Concatenate all possible characters
    local all_chars="$lower$upper$digits$special"

    # Initialize password with one character from each category
    password="${lower:RANDOM%${#lower}:1}${upper:RANDOM%${#upper}:1}${digits:RANDOM%${#digits}:1}${special:RANDOM%${#special}:1}"

    # Append random characters to meet desired length
    local remaining_length=$((length - 4))
    for ((i=0; i<remaining_length; i++)); do
        password+=${all_chars:RANDOM%${#all_chars}:1}
    done

    # Shuffle password characters to make it more random
    password=$(shuf -n${length} -e "$(echo ${password} | fold -w1)" | tr -d '\n')

    # Check if the password meets the criteria
    if [[ "$password" =~ [[:lower:]] && "$password" =~ [[:upper:]] && "$password" =~ [[:digit:]] && "$password" =~ [[:punct:]] ]]; then
        echo "$password"
    else
        generate_password
    fi
}

create_user() {
    
    local user=$1
    local pass=$2
    local first=$3
    local last=$4
    local eml=$5
    
    ipa user-add "$user" --first="$first" --last="$last" --password --email="$eml" >/dev/null 2>&1 <<  EOF
        $pass
EOF
    ret=$?
    echo "$user,$pass,$first,$last,$eml $ret"
}

change_password() {
    #changing password
    local user=$1
    local pass=$2

    ipa user-mod "$user" --password >/dev/null 2>&1 << EOF
        $pass
EOF
    ret=$?
    echo "$user,$pass $ret"
}

create_existing_user() {
    local user=$1
    local pass=$2
    local first
    local last
    local ch=$3
    first=$(ipa user-show "$user" | grep -iE "first name:" | cut -d : -f 2 | tr -d ' ')
    last=$(ipa user-show "$user" | grep -iE "last name:" | cut -d : -f 2 | tr -d ' ')
    email_id=$(ipa user-show "$user" | grep -i "Email address" | cut -d : -f 2 | tr -d ' ')

    ret=$?
    if [[ "$ret" -eq 0 ]]; then
        if [[ "$ch" =~ ^[ik]$ ]]; then
            new_user="$user""_wifi"
            new_userd=$(create_user "$new_user" "$pass" "$first" "$last" "$email_id")
        elif [[ "$ch" =~ ^[jl]$ ]]; then
            new_user="$user""_vpn"
        new_userd=$(create_user "$new_user" "$pass" "$first" "$last" "$email_id")
        fi
    fi
    echo "$new_userd $ret"
}

delete_user() {
    local user=$1
    ipa user-del "$user" >/dev/null 2>&1
    ret=$?
    echo "$user $ret"
}

add_user_in_grp() {
    local user=$2
    # verify=$(ipa group-add-member "$1" --users="$user" | grep -i "Member users")
    if ipa group-add-member "$1" --users="$user" >/dev/null 2>&1; then
        echo 0
    else
        echo 1
    fi
}

filename() {
    local fileoption=$1

    if [[ $fileoption =~ ^[aei]$ ]]; then
        echo "/home/admin_dir/my_package/irage_server_and_wifi_user_details.csv"
    elif [[ $fileoption =~ ^[bfj]$ ]]; then
        echo "/home/admin_dir/my_package/irage_vpn_user_details.csv"
    elif [[ $fileoption =~ ^[cgk]$ ]]; then
        echo "/home/admin_dir/my_package/qi_wifi_user_details.csv"
    elif [[ $fileoption =~ ^[dhl]$ ]]; then
        echo "/home/admin_dir/my_package/qi_vpn_user_details.csv"
    fi
}

choice=$1
i=0
# Main script
while [ -z "$choice" ]; do
    if [[ $i -gt 0 ]]; then
        echo -e "\033[0;31m field cannot be empty \033[0m"
    fi
    echo -e "\033[0;93mchoose option from below:-\n \na:  Adding users for IRAGE Server and WiFi
b:  Adding users for Irage VPN (format <username>_vpn)
c:  Adding users for QI WiFi 
d:  Adding users for QI VPN (format <username>_vpn)
e:  Changing password of user for IRAGE Server and WiFi 
f:  Changing password of user for IRAGE VPN 
g:  Changing password of user for QI WiFi 
h:  Changing password of user for QI VPN 
i:  Adding existing user for IRAGE WiFi (format <existing username>)
j:  Adding existing user for IRAGE VPN (format <existing username>)
k:  Adding existing user for QI WiFi (format <existing username>)
l:  Adding existing user for QI VPN (format <existing username>)
m:  Deleting users 
n:  To add user in group 

Make your choice by entering alphabet that is infront of option\033[0m"
    read -rp ":" choice
    ((i += 1))
    if [[ $i -eq 5 ]]; then
        echo -e "\033[1;31m exited: you didn't gave any input \033[0m"
        exit 1
    fi

done

if [[ "$choice" =~ ^[a-m]$ ]]; then
    file=$(filename "$choice")
fi

mode=$2

i=0
while [ -z "$mode" ]; do
    if [[ $i -gt 0 ]]; then
        echo -e "\033[0;31m Field cannot be empty \033[0m"
    fi
    echo -e "\033[0;93mEnter:
o: For passing input manually
p: For passing input from csv file \033[0m"
    read -rp ":" mode
    ((i += 1))
    if [[ $i -eq 5 ]]; then
        echo -e "\033[1;31m Exited: you didn't gave any input \033[0m"
        exit 1
    fi
done

csv_file=''

if [[ "$mode" == "p" ]]; then
    i=0
    while [ -z "$csv_file" ]; do
        if [[ $i -gt 0 ]]; then
            echo -e "\033[0;31m Field cannot be empty \033[0m"
        fi
        echo "Enter csv file path"
        read -rp : csv_file
        ((i += 1))
        if [[ $i -eq 5 ]]; then
            echo -e "\033[1;31m Exited: you didn't gave any input \033[0m"
            exit 1
        fi
    done

    if [[ "$choice" =~ ^[e-n]$ ]]; then
        if [[ $(cat $csv_file) =~ "," ]]; then
            users=($(cat $csv_file | sed '1d' | cut -d , -f 1))
        else
            users=($(cat $csv_file | sed '1d'))
        fi
    elif [[ "$choice" =~ ^[a-d]$ ]]; then
        users=($(cat $csv_file | sed '1d' | cut -d , -f 1))
        first=($(cat $csv_file | sed '1d' | cut -d , -f 2))
        last=($(cat $csv_file | sed '1d' | cut -d , -f 3))
        emlid=($(cat $csv_file | sed '1d' | cut -d , -f 4))
    fi

elif [[ "$mode" == "o" ]]; then

    user=$3
    groupname=''
    groupnum=''

    if [[ "$choice" =~ ^[e-n]$ ]]; then

        if [[ "$choice" == "n" ]]; then
            grps=($(ipa group-find | grep -i "group name:" | cut -d : -f 2))
            i=0
            while [ -z "$groupname" ]; do
                n=1;for i in "${grps[@]}"; do echo "$n:$i";((n=n+1)); done | column
                if [[ $i -gt 0 ]]; then
                    echo -e "\033[0;31m field cannot be empty \033[0m"
                fi
                echo -e "\033[0;93mEnter number before <number>:group name \033[0m"
                read -rp ":" groupnum
                ((i += 1))
                if [[ $i -eq 5 ]]; then
                    echo -e "\033[1;31m exited: you didn't gave any input \033[0m"
                    exit 1
                fi
                groupname="${grps[$(("$groupnum"-1))]}"
            done
            
        fi

        i=0
        while [ -z "$user" ]; do
            if [[ $i -gt 0 ]]; then
                echo -e "\033[0;31m Field cannot be empty \033[0m"
            fi
            echo -e "\033[0;93mEnter username [ user ] or usernames [ user1 user2 user3 ... ] \033[0m"
            read -rp ":" user
            ((i += 1))
            if [[ $i -eq 5 ]]; then
                echo -e "\033[1;31m Exited: you didn't gave any input \033[0m"
                exit 1
            fi
        done

        IFS=' ' read -ra users <<<"$user"


    elif [[ "$choice" =~ ^[a-d]$ ]]; then

        declare -A my_dict

        my_dict[username]=''
        my_dict[firstname]=''
        my_dict[lastname]=''
        my_dict[email_id]=''

        bl=false

        keys=(username firstname lastname email_id)

        while [ "$value" != 'done' ];do

            for key in "${keys[@]}"; do
                i=0
                value=''
                
                while [ -z "$value" ]; do
                    if [[ $i -gt 0 ]]; then
                        echo -e "\033[0;31m field cannot be empty \033[0m"
                    fi
                    [ "$bl" == true ] && echo -e "\033[0;93m Enter $key (enter 'done' if you don't want to add any more user) \033[0m" \
                    || echo -e "\033[0;93mEnter $key \033[0m"
                    read -rp ":" value
                
                    ((i += 1))
                    if [[ $i -eq 5 ]]; then
                        echo -e "\033[1;31m exited: you didn't gave any input \033[0m"
                        exit 1
                    fi
                done
                if [ "$value" == 'done' ]; then
                    break # Break out of both the inner and outer loop
                else
                    # Concatenate the new value with the existing value, separated by a space
                    my_dict[$key]="${my_dict[$key]} $value"
                    echo "Entered $key : ${my_dict[$key]}"
                fi
            done
            bl=true
            echo "---------------------------------------------------------------------------"
        done    

        IFS=' ' read -ra users <<< "${my_dict[username]}"
        IFS=' ' read -ra first <<< "${my_dict[firstname]}"
        IFS=' ' read -ra last <<< "${my_dict[lastname]}"
        IFS=' ' read -ra emlid <<< "${my_dict[email_id]}"

    else
        echo -e "\033[1;31m-----------------invalid option entered------------------\033[0m"
    fi
else
    echo -e "\033[1;31m-----------------invalid option entered------------------\033[0m"
fi


result=()
err=()
cmpltd=()
# Generate passwords
passwords=()
for ((index = 0; index < ${#users[@]}; index++)); do
    if [[ "$choice" =~ ^[a-l]$ ]]; then
        echo "Generating password for : ${users[$index]}"
        password=$(generate_password)
        # Check if the password already exists
        passwords+=("$password")
        for existing_password in "${passwords[@]}"; do
            if [[ "$existing_password" == "$password" ]]; then
                password=$(generate_password)
                break
            fi
        done

        pass="${users[$index]}$password"
        
    fi
    # change_password "$user" "$pass"

    # executing Functions
    if [[ $choice =~ ^[a-d]$ ]]; then
        echo "Adding : ${users[$index]} : with its generated password"
        rs=$(create_user "${users[$index]}" "$pass" "${first[$index]}" "${last[$index]}" "${emlid[$index]}")
        res=$(echo "$rs" | cut -d ' ' -f 1)
        ret=$(echo "$rs" | cut -d ' ' -f 2)
    elif [[ $choice =~ ^[e-h]$ ]]; then
        echo "Resetting password for : ${users[$index]}"
        rs=$(change_password "${users[$index]}" "$pass")
        res=$(echo "$rs" | cut -d ' ' -f 1)
        ret=$(echo "$rs" | cut -d ' ' -f 2)
    elif [[ $choice =~ ^[i-l]$ ]]; then
        if [[ $choice =~ ^[ik]$ ]]; then
            echo "Creating user : ${users[$index]}""_wifi : using existing user ${users[$index]}"
        else
            echo "Creating user : ${users[$index]}""_vpn : using existing user ${users[$index]}"
        fi
        rs=$(create_existing_user "${users[$index]}" "$pass" "$choice")
        res=$(echo "$rs" | cut -d ' ' -f 1)
        ret=$(echo "$rs" | cut -d ' ' -f 2)
    elif [[ $choice == "m" ]]; then
        echo "Deleting user : ${users[$index]} :"
        rs=$(delete_user "${users[$index]}")
        res=$(echo "$rs" | cut -d ' ' -f 1)
        ret=$(echo "$rs" | cut -d ' ' -f 2)
    elif [[ $choice == "n" ]]; then
        echo "Adding user : ${users[$index]} : in : $groupname : "
        ret=$(add_user_in_grp "$groupname" "${users[$index]}")
        
    fi

    echo "exit value: $ret"
    if [[ $ret -ne 0 ]]; then
        err+=("${users[$index]}")
    else 
        result+=("$res")
        euser=$(echo "$res" | cut -d , -f 1)
        if [[ $choice =~ ^[ai]$ ]]; then
            echo "Adding user : $euser : in : irage wifi : "
            echo " exit value: $(add_user_in_grp "irage_wifi" "$euser")"
        elif [[ $choice =~ ^[ck]$ ]]; then
            echo "Adding user : $euser : in : qi wifi : "
            echo " exit value: $(add_user_in_grp "qi_wifi" "$euser")"
        elif [[ $choice == "d" ]]; then
            echo "Adding user : $euser : in : qi vpn : "
            echo " exit value: $(add_user_in_grp "qi_vpn" "$euser")"
        elif [[ $choice =~ ^[jl]$ ]]; then
                grp=$(ipa user-show "${users[$index]}" | grep -i "Member of groups:" | cut -d : -f 2 | tr -d ' ')
                ng=()
                IFS=',' read -ra ar <<< "$grp"
                for i in "${ar[@]}";do 
                    if [[ $i = *"vpn"* ]];then 
                        ng+=("$i")
                fi
                done
                for ug in "${ng[@]}"; do
                    echo "Adding user : $euser : in : $ug : "
                    echo "exit value: $(add_user_in_grp "$ug" "$euser")"
                done
        fi
        cmpltd+=("${users[$index]}")
    fi

    echo "-----------------------------------------------------------------------------"
done

if [[ ${#result[@]} -ne 0 ]]; then
    json_array=$(printf "%s\n" "${result[@]}" | jq -nR '[inputs]')
    python "/home/admin_dir/my_package/user_manage.py" "$json_array" "$file" "$choice"
fi

echo "--------------Task completed for--------------"
printf "%s\n" "${cmpltd[@]}"

echo ""

echo "--------------Task failed for--------------"
printf "%s\n" "${err[@]}"

rsync -avhP /home/admin_dir/my_package/*.csv /root/usermanage_csv_bkp/
if [[ $? -eq 0 ]]; then
    echo "csv file backup has been taken"
fi