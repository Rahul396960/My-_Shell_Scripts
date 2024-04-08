import csv
from irage_helper import send_mail

class mailing:
# user = []
# password = []
# email = []

# with open('/home/irage/scripts/Script_irage/irage/user_password/irage_vpn_user_passwords.csv', 'r') as csvfile:
#     # Read all lines into a list
#     lines = csvfile.readlines()

#     # Loop through the last two lines
#     for line in lines[1:]:
#         # Split the line after removing whitespace from each line
#         splitted = line.strip().split(',')

#         # Extract user and sample values
#         user.append(splitted[0])
#         password.append(splitted[1])
#         email.append(splitted[4])

# # Print each element one by one
# #for k in range(len(user))[1:]:
# for k in range(len(user)):

#     # print(f"user:{user[k]} pass:{password[k]} eml:{email[k]}")
#     # lowercase_word = user[k].lower()
#     # send_mail("rahul.sharma@irage.in","Rahul Sharma",[f"{lowercase_word}@quantinsti.com","system@irage.in"],"New Wifi and VPN password",f"Your new wifi and vpn(only if you use vpn) credential is: <br> username={lowercase_word} <br> password={password[k]} <br><br> please let us kow if have any query. <br><br> Regards,<br>Rahul Sharma")
#     send_mail("rahul.sharma@irage.in","Rahul Sharma",[f"{email[k]}"],"New VPN password",f"Your new VPN credential is: <br> username={user[k]} <br> password={password[k]} <br><br> Your previous credentials will be deactivated after 7 days on 22-march-2024 for VPN login and will work only for server and wifi login<br><br>please start using this new credentials from your next VPN login and let us know if you face any issue. <br><br> Regards,<br>Rahul Sharma")
#     print(f"sending to {email[k]}\n just for testing purpose\n username={user[k]} \n password= {password[k]}")
#     print("--------------------------------")

    def get_user_details(self,username, csv_file):
        with open(csv_file, 'r', newline='') as file:
            reader = csv.DictReader(file)
            for row in reader:
                if row['Username'] == username:
                    return row

        return None

    def get_all_user_details(self):
        with open('/home/irage/scripts/Script_irage/irage/user_password/qi_wifi_user_details.csv', 'r', newline='') as file:
            reader = csv.DictReader(file)
            for row in reader:
                # print(f"username = {row['Username']} \n password = {row['Password']}")
                self.qi_mail(row['Username'],row['Password'],row['Email_id'])

    def vpn_mail(self,username,password,email):
            # print(f"user:{user[k]} pass:{password[k]} eml:{email[k]}")
        # lowercase_word = user[k].lower()
        # send_mail("rahul.sharma@irage.in","Rahul Sharma",[f"{lowercase_word}@quantinsti.com","system@irage.in"],"New Wifi and VPN password",f"Your new wifi and vpn(only if you use vpn) credential is: <br> username={lowercase_word} <br> password={password[k]} <br><br> please let us kow if have any query. <br><br> Regards,<br>Rahul Sharma")
        send_mail("rahul.sharma@irage.in","Rahul Sharma",[f"{email}"],"New VPN Credentials",f"Your new VPN credentials are: <br> username={username} <br> password={password} <br><br> Please reply us on system@irage.in, if you face any issue. <br><br>Regards,<br>Rahul Sharma")
        print(f"sending to {email}\n just for testing purpose\n username={username} \n password= {password}")
        print("--------------------------------")

    def qi_wifi_mail(self,username,password,email):
            # print(f"user:{user[k]} pass:{password[k]} eml:{email[k]}")
        # lowercase_word = user[k].lower()
        # send_mail("rahul.sharma@irage.in","Rahul Sharma",[f"{lowercase_word}@quantinsti.com","system@irage.in"],"New Wifi and VPN password",f"Your new wifi and vpn(only if you use vpn) credential is: <br> username={lowercase_word} <br> password={password[k]} <br><br> please let us kow if have any query. <br><br> Regards,<br>Rahul Sharma")
        send_mail("rahul.sharma@irage.in","Rahul Sharma",[f"{email}"],"New Wifi Credentials",f"Your new Wifi credentials are: <br> username={username} <br> password={password} <br><br> Please reply us on system@irage.in, if you face any issue. <br><br>Regards,<br>Rahul Sharma")
        print(f"sending to {email}\n just for testing purpose\n username={username} \n password= {password}")
        print("--------------------------------")

    def irage_wifi_mail(self,username,password,email):
            # print(f"user:{user[k]} pass:{password[k]} eml:{email[k]}")
        # lowercase_word = user[k].lower()
        # send_mail("rahul.sharma@irage.in","Rahul Sharma",[f"{lowercase_word}@quantinsti.com","system@irage.in"],"New Wifi and VPN password",f"Your new wifi and vpn(only if you use vpn) credential is: <br> username={lowercase_word} <br> password={password[k]} <br><br> please let us kow if have any query. <br><br> Regards,<br>Rahul Sharma")
        send_mail("rahul.sharma@irage.in","Rahul Sharma",[f"{email}"],"New Wifi and Server Credentials",f"Your new Wifi and server credentials are: <br> username={username} <br> password={password} <br><br> You will be asked to change the password at your first login, after changing the password same will work for your Wifi athentication as well. Please reply us on system@irage.in, if you face any issue. <br><br>Regards,<br>Rahul Sharma")
        print(f"sending to {email}\n just for testing purpose\n username={username} \n password= {password}")
        print("--------------------------------") 

    def put_user_details(self):
        csv_file = '/home/irage/scripts/Script_irage/irage/user_password/irage_vpn_user_passwords.csv'  # Specify the path to your CSV file
        
        username = input("Enter the username: ")

        user_details = self.get_user_details(username, csv_file)
        # print(user_details)
        if user_details:
            self.mail(user_details['Username'],user_details['Password'],user_details['Email_id'])
        else:
            print("User not found.")

if __name__ == "__main__":

    obj=mailing()

    # get_all_user_details()
    obj.get_all_user_details()
