import csv
from irage_helper import send_mail

class mailing:
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
                self.qi_wifi_mail(row['Username'],row['Password'],row['Email_id'])

    def vpn_mail(self,username,password,email):
        send_mail("rahul.sharma@irage.in","Rahul Sharma",[f"{email}"],"New VPN Credentials",f"Your new VPN credentials are: <br> username={username} <br> password={password} <br><br> Please reply us on system@irage.in, if you face any issue. <br><br>Regards,<br>Rahul Sharma")
        print(f"sending VPN mail to {email}\n just for testing purpose\n username={username} \n")
        print("--------------------------------")

    def qi_wifi_mail(self,username,password,email):
        send_mail("rahul.sharma@irage.in","Rahul Sharma",[f"{email}"],"New Wifi Credentials",f"Your new Wifi credentials are: <br> username={username} <br> password={password} <br><br> Please reply us on system@irage.in, if you face any issue. <br><br>Regards,<br>Rahul Sharma")
        print(f"sending QI wifi mail to {email}\n just for testing purpose\n username={username} \n")
        print("--------------------------------")

    def irage_wifi_mail(self,username,password,email):
        send_mail("rahul.sharma@irage.in","Rahul Sharma",[f"{email}"],"New Wifi and Server Credentials",f"Your new Wifi and server credentials are: <br> username={username} <br> password={password} <br><br> You will be asked to change the password at your first login, after changing the password same will work for your Wifi athentication as well. Please reply us on system@irage.in if you face any issue. <br><br>Regards,<br>Rahul Sharma")
        print(f"sending Irage wifi mail to {email}\n just for testing purpose\n username={username} \n")
        print("--------------------------------") 

    def put_user_details(self):
        csv_file = '/home/irage/scripts/Script_irage/irage/user_password/irage_vpn_user_details_bkp.csv'  # Specify the path to your CSV file
        
        username = input("Enter the username: ")

        user_details = self.get_user_details(username, csv_file)
        # print(user_details)
        if user_details:
            self.vpn_mail(user_details['Username'],user_details['Password'],user_details['Email_id'])
        else:
            print("User not found.")

if __name__ == "__main__":

    obj=mailing()

    # get_all_user_details()
    obj.put_user_details()
