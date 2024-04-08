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
    
    ipa user-add "$user" --first="$first" --last="$last" --password --email_id=''="$eml" >/dev/null 2>&1 <<  EOF
        $pass
EOF
    ret=$?
    echo "$user,$pass,$first,$last,$eml $ret"
}

change_password() {
    #changing password
    local user=$1
    local pass=$2
    echo "Changing password for: $user"
    ipa user-mod "$user" --password >/dev/null 2>&1 <<EOF
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

    first=$(ipa user-show "$user" | grep -iE "first name:" | cut -d : -f 2 | tr -d ' ')
    last=$(ipa user-show "$user" | grep -iE "last name:" | cut -d : -f 2 | tr -d ' ')
    email_id=$(ipa user-show "$user" | grep -i "Email_id='' address" | cut -d : -f 2 | tr -d ' ')
    new_user="$user""_vpn"
    new_userd=$(create_user "$new_user" "$pass" "$first" "$last" "$email_id")

    echo "$new_userd"
}

delete_user() {
    local user=$1
    ipa user-del "$user" 
    ret=$?
    echo "$user $ret"
}

add_user_in_grp() {
    verify=$(ipa group-add-member "$1" --users="$2" | grep -i "Member users")
    if [[ "$verify" =~ $user ]]; then
        return 0
    else
        return 1
    fi
}

filename() {
    local fileoption=$1

    if [[ $fileoption =~ ^[aei]$ ]]; then
        echo "$(pwd)""/irage_server_and_wifi_user_details.csv"
    elif [[ $fileoption =~ ^[bfj]$ ]]; then
        echo "$(pwd)""/irage_vpn_user_details.csv"
    elif [[ $fileoption =~ ^[cgk]$ ]]; then
        echo "$(pwd)""/qi_wifi_user_details.csv"
    elif [[ $fileoption =~ ^[dhl]$ ]]; then
        echo "$(pwd)""/qi_vpn_user_details.csv"
    fi
}

choice=''
i=0
# Main script
while [ -z "$choice" ]; do
    if [[ $i -gt 0 ]]; then
        echo -e "\033[0;31m field cannot be empty \033[0m"
    fi
    echo -e "\033[0;93mchoose option from below:-\n \na:  Adding users for IRAGE Server and WiFi
b:  Adding users for Irage VPN 
c:  Adding users for QI WiFi 
d:  Adding users for QI VPN 
e:  Changing password of user for IRAGE WiFi 
f:  Changing password of user for IRAGE VPN 
g:  Changing password of user for QI WiFi 
h:  Changing password of user for QI VPN 
i:  Adding existing user for IRAGE WiFi 
j:  Adding existing user for IRAGE VPN 
k:  Adding existing user for QI WiFi 
l:  Adding existing user for QI VPN 
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


user=''
groupname=''

if [[ "$choice" =~ ^[a-m]$ ]]; then
    file=$(filename $choice)
fi

if [[ "$choice" =~ ^[e-n]$ ]]; then

    if [[ "$choice" == "n" ]]; then
        grps=($(ipa group-find | grep -i "group name:" | cut -d : -f 2))
        i=0
        while [ -z "$groupname" ]; do
            n=1;for i in "${grps[@]}"; do echo "$n:$i";((n=n+1)); done | column
            if [[ $i -gt 0 ]]; then
                echo -e "\033[0;31m field cannot be empty \033[0m"
            fi
            echo -e "\033[0;93m enter number before <number>:group name \033[0m"
            read -rp ":" groupnum
            ((i += 1))
            if [[ $i -eq 5 ]]; then
                echo -e "\033[1;31m exited: you didn't gave any input \033[0m"
                exit 1
            fi
        done
        groupname=$groupnum
    fi

    i=0
    while [ -z "$user" ]; do
        if [[ $i -gt 0 ]]; then
            echo -e "\033[0;31m field cannot be empty \033[0m"
        fi
        echo -e "\033[0;93m enter username [ user ] or usernames [ user1 user2 user3 ... ] \033[0m"
        read -rp ":" user
        ((i += 1))
        if [[ $i -eq 5 ]]; then
            echo -e "\033[1;31m exited: you didn't gave any input \033[0m"
            exit 1
        fi
    done

    IFS=' ' read -ra users <<<"$user"

    # for i in "${users[@]}";do 
    #     ipa user-show $i >/dev/null 2>&1
    #     if [[ $? -eq 0 ]]; then 
    #         echo "$i : user exist"
    #     else 
    #         echo "$i: user doesn't exit"
    #         exit 1
    #     fi 
    # done

elif [[ "$choice" =~ ^[a-d]$ ]]; then

    declare -A my_dict

    username='enter username'
    firstname='enter firstname'
    lastname='enter lastname'
    email_id='enter user email_id'

    my_dict["$username"]=''
    my_dict["$firstname"]=''
    my_dict["$lastname"]=''
    my_dict["$email_id"]=''

    bl=false

    keys=("$username" "$firstname" "$lastname" "$email_id")

    while [ "$value" != 'done' ];do

        for key in "${keys[@]}"; do
            i=0
            value=''
            [ "$bl" == true ] && key="$key (enter 'done' if you don't want to add any more user)"
            while [ -z "$value" ]; do
                if [[ $i -gt 0 ]]; then
                    echo -e "\033[0;31m field cannot be empty \033[0m"
                fi
                echo -e "\033[0;93m $key \033[0m"
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
                my_dict[$key]+=" $value"
                echo "$key : ${my_dict[$key]}"
            fi
        done
        bl=true
        echo "-----------------------------------"
    done    

    IFS=' ' read -ra users <<< "${my_dict["$username"]}"
    IFS=' ' read -ra first <<< "${my_dict["$firstname"]}"
    IFS=' ' read -ra last <<< "${my_dict["$lastname"]}"
    IFS=' ' read -ra emlid <<< "${my_dict["$email_id"]}"

    echo "usernames:" "${my_dict["$username"]}"
    echo "firstnames:" "${my_dict["$firstname"]}"
    echo "lastnames:" "${my_dict["$lastname"]}"
    echo "emlid:" "${my_dict["$email_id"]}"
fi

result=()
err=()
cmpltd=()
# Generate passwords
passwords=()
for ((index = 0; index < ${#users[@]}; index++)); do
    if [[ "$choice" =~ ^[a-l]$ ]]; then
        echo "Generating password for: ${users[$index]}"
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
        echo "Resetting password for : ${users[$index]} :"
        rs=$(change_password "${users[$index]}" "$pass")
        res=$(echo "$rs" | cut -d ' ' -f 1)
        ret=$(echo "$rs" | cut -d ' ' -f 2)
    elif [[ $choice =~ ^[i-l]$ ]]; then
        echo "Creating user : ${users[$index]}""_vpn : using existing user ${users[$index]}"
        rs=$(create_existing_user "${users[$index]}" "$pass")
        res=$(echo "$rs" | cut -d ' ' -f 1)
        ret=$(echo "$rs" | cut -d ' ' -f 2)
    elif [[ $choice == "m" ]]; then
        echo "Deleting user : ${users[$index]} :"
        rs=$(delete_user "${users[$index]}")
        res=$(echo "$rs" | cut -d ' ' -f 1)
        ret=$(echo "$rs" | cut -d ' ' -f 2)
    elif [[ $choice == "n" ]]; then
        ret=$(add_user_in_grp "$groupname" "${users[$index]}")
        
    fi

    echo "exit value: $ret"
    if [[ $ret -ne 0 ]]; then
        err+=("${users[$index]}")
    else 
        result+=("$res")
        if [[ $choice =~ ^[ai]$ ]]; then
            echo "Adding user : ${users[$index]} : in : irage wifi : "
            add_user_in_grp "irage_wifi" "${users[$index]}"
        elif [[ $choice =~ ^[ck]$ ]]; then
            echo "Adding user : ${users[$index]} : in : irage qi : "
            add_user_in_grp "qi_wifi" "${users[$index]}"
        elif [[ $choice =~ ^[jl]$ ]]; then
                grp=$(ipa user-show "${users[$index]}" | grep -i "Member of groups:" | cut -d : -f 2 | tr -d ' ')
                ng=()
                IFS=',' read -ra ar <<< $grp
                for i in "${ar[@]}";do 
                    if [[ $i = *"vpn"* ]];then 
                        ng+=("$i")
                fi
                done
                for ug in "${ng[@]}"; do
                    echo "Adding user : ${users[$index]} : in : $ug : "
                    add_user_in_grp "$ug" "$(echo $res | cut -d , -f 1)"
                done
            cmpltd+=("${users[$index]}")
        fi
    fi

    echo "----------------------------------------------"
done

# if [[ ${#result[@]} -ne 0 ]]; then
#     json_array=$(printf "%s\n" "${result[@]}" | jq -R . | jq -s .)
#     python "$(pwd)"/my_package/user_manage.py "$json_array" "$file" "$choice"
# fi

echo "--------------Task completed for--------------"
printf "%s\n" "${cmpltd[@]}"

echo ""

echo "--------------Task failed for--------------"
printf "%s\n" "${err[@]}"