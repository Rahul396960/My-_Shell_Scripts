import csv
import json
import sys
import os
import re
from mail_ing import mailing as mail

class UserManager:

    def file_edit(arr, filename, mode):
        with open(filename, mode, newline='') as csvfile:
            csvwriter = csv.writer(csvfile)
            for line in arr:
                csvwriter.writerow(line)  # write data
                print(line)

    def remove_username_from_file(file_path, username):
        with open(file_path, 'r') as csvfile:
            lines = csvfile.readlines()
        
        with open(file_path, 'w') as csvfile:
            for line in lines:
                if username not in line:
                    csvfile.write(line)

    def changing_password(user,password,file_path,opt):
        with open(file_path, 'r', newline='') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                if row['Username'] == user:
                    if re.match('[fh]',opt):
                        mail.vpn_mail(user,password,row['Email_id'])
                    elif re.match('[e]',opt):
                        mail.irage_wifi_mail(user,password,row['Email_id'])
                    elif re.match('[g]',opt):
                        mail.qi_wifi_mail(user,password,row['Email_id'])

if __name__ == "__main__":
    um=UserManager()
    json_array = sys.argv[1]
    file = sys.argv[2]
    option=sys.argv[3]
    header = ['Username','Firstname','Lastname','Email_id']

    # Parse the JSON array into a Python list
    my_array = json.loads(json_array)

    if re.match('[a-di-l]', option):

        list1 = []
        for data in my_array:
            elements = data.split(',')  # Split the data by comma
            # print('0: %s 1: %s 2: %s 3: %s 4: %s', elements[0], elements[1], elements[2], elements[3], elements[4])
            # Append Username, Firstname, Lastname, Email id to list1
            list1.append([elements[0], elements[2], elements[3], elements[4]])
            # Append Username, Password, Email id to list2
            if re.match('^[bdfhjl]$',option):
                mail.vpn_mail(elements[0], elements[1], elements[4])
            elif re.match('^[aei]$',option):
                mail.irage_wifi_mail(elements[0], elements[1], elements[4])
            elif re.match('^[cgk]$',option):
                mail.qi_wifi_mail(elements[0], elements[1], elements[4])

        if os.path.exists(file) and os.stat(file).st_size > 0:  # Check if file exists and is not empty
            um.file_edit(list1,file,'a')
        else:
            list1.insert(0, header)  # Insert header at the beginning
            um.file_edit(list1,file,'w')
    
    elif option == 'm':
        file_paths = [
            "/home/admin_dir/my_package/irage_server_and_wifi_user_details.csv",
            "/home/admin_dir/my_package/irage_vpn_user_details.csv",
            "/home/admin_dir/my_package/qi_wifi_user_details.csv",
            "/home/admin_dir/my_package/qi_vpn_user_details.csv"
        ]

        for file_path in file_paths:
            for username in my_array:
                um.remove_username_from_file(file_path, username)

    elif re.match('[e-h]', option):
        for data in my_array:
            element = data.split(',')
            um.changing_password(element[0],element[1],file,option)

