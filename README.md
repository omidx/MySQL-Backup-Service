# MySQL Backup Service Setup
This guide provides step-by-step instructions to set up a MySQL backup script using Docker containers and 'systemd' on a Linux server. The script performs a full backup every 12 hours and a differential backup every hour. It also ensures old backups are deleted after seven days.

#### Prerequisites ####
1) Docker installed and running
2) MySQL container running
3) Basic knowledge of shell scripting and systemd

#### Step 1: Download the Backup Script ####
Clone the backup script repository from the following GitHub link:
```bash
git clone https://github.com/omidx/repository.git
```
Once downloaded, make the script executable:
```bash
chmod +x backup_script.sh
```
#### Step 2: Create a systemd Service File ####
Create a systemd service file named 'backup_service.service' with the following content:
```bash
[Unit]
Description=MySQL Backup Service
After=docker.service
Requires=docker.service

[Service]
ExecStart=/path/to/backup_script.sh
Restart=always
RestartSec=10
User=your_user_name
WorkingDirectory=/path/to/
StandardOutput=append:/var/log/mysql_backup.log
StandardError=append:/var/log/mysql_backup_error.log

[Install]
WantedBy=multi-user.target
```
Copy the service file to the systemd directory:
```bash
sudo cp backup_service.service /etc/systemd/system/
```

#### Step 3: Load and Enable the Service ####
Reload systemd to recognize the new service:
```bash
sudo systemctl daemon-reload
```
Enable the service to start on boot:
```bash
sudo systemctl enable backup_service
```
Start the service:
```bash
sudo systemctl start backup_service
```

#### Step 4: Verify the Service ####
Check the status of the service to ensure it is running correctly:
```bash
sudo systemctl status backup_service
```

You should see output indicating that the service is active and running. If there are any issues, check the logs specified in the service file ('/var/log/mysql_backup.log' and '/var/log/mysql_backup_error.log') for more details.

Your MySQL backup script is now set up to run automatically using 'systemd'. It will create full and differential backups at specified intervals and clean up old backups as needed. This setup ensures your MySQL data is regularly backed up and managed efficiently.
