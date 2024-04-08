import csv
import json
import sys
import os
import re
from my_package.mail_ing import mailing

class user_manage:
    # bash_script_path = "group.sh"  # Define the path to the Bash script

    # output = subprocess.check_output(["bash", bash_script_path])    # Execute the Bash script and capture its output

    # lines = output.decode().split("\n") # Convert the byte output to string and split it into lines

    # lines = [line for line in lines if line]    # Remove any empty lines

    # # Hdr_row=['Username', 'Password', 'Firstname', 'Lastname', "Email id"]

    # Get the JSON array from the command-line arguments
    def file_edit(self,arr, filename, mode):
        with open(filename, mode, newline='') as csvfile:
            csvwriter = csv.writer(csvfile)
            for line in arr:
                csvwriter.writerow(line)  # write data
                print(line)

    def remove_username_from_file(self,file_path, username):
        with open(file_path, 'r') as csvfile:
            lines = csvfile.readlines()
        
        with open(file_path, 'w') as csvfile:
            for line in lines:
                if username not in line:
                    csvfile.write(line)

    def changing_password(self,user,password,file_path,opt):
        with open(file_path, 'r', newline='') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                if row['Username'] == user:
                    if re.match('[bfj]',opt):
                        mailing.vpn_mail(user,password,row['Email_id'])
                    elif re.match('[aei]',opt):
                        mailing.vpn_mail(user,password,row['Email_id'])
                    elif re.match('[cgk]',opt):
                        mailing.vpn_mail(user,password,row['Email_id'])


    json_array = sys.argv[1]
    file = sys.argv[2]
    option=sys.argv[3]
    header = ['Username','Firstname','Lastname','Email id']

    # Parse the JSON array into a Python list
    my_array = json.loads(json_array)

    if re.match('[a-di-l]', option):

        list1 = []
        list2 = []
        for data in my_array:
            elements = data.split(',')  # Split the data by comma
            # Append Username, Firstname, Lastname, Email id to list1
            list1.append([elements[0], elements[2], elements[3], elements[4]])
            # Append Username, Password, Email id to list2
            if re.match('[bfj]',option):
                mailing.vpn_mail(elements[0], elements[1], elements[4])
            elif re.match('[aei]',option):
                mailing.irage_wifi_mail(elements[0], elements[1], elements[4])
            elif re.match('[cgk]',option):
                mailing.qi_wifi_mail(elements[0], elements[1], elements[4])

        if os.path.exists(file) and os.stat(file).st_size > 0:  # Check if file exists and is not empty
            file_edit(list1,file,'a')
        else:
            list1.insert(0, header)  # Insert header at the beginning
            file_edit(list1,file,'w')
    
    elif option == 'm':
        file_paths = [
            os.getcwd() + "/irage_server_and_wifi_user_details.csv",
            os.getcwd() + "/irage_vpn_user_details.csv",
            os.getcwd() + "/qi_wifi_user_details.csv",
            os.getcwd() + "/qi_vpn_user_details.csv"
        ]

        for file_path in file_paths:
            for username in my_array:
                remove_username_from_file(file_path, username)

    elif re.match('[e-h]', option):
        for data in my_array:
            element = data.split(',')
            changing_password(element[0],element[1],file,option)

