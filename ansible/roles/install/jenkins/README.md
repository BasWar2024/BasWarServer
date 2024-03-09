jinkens
========
* Jenkinsdevelop
    ```
    sudo systemctl stop jenkins
    sudo vi /etc/sysconfig/jenkins,JENKINS_USERdevelop
    sudo chown -R develop:develop /var/lib/jenkins
    sudo chown -R develop:develop /var/cache/jenkins
    sudo chown -R develop:develop /var/log/jenkins
    sudo systemctl start jenkins
    ```
* jenkins
```
    0. : http://$IP:8080/
    1. 
    2. [Manager Jenkins],[Manage Plugins],[Available],SSH,'SSH'
    3. [Manager Jenkins],[Manage Credentials],'Domainsglobal',,+,Description''
    4. [Manager Jenkins],[Configure System],[SSH remote hosts],'Add',Hostnameip,Port22,Credentials'',
    5. [Manager Jenkins],[Configure System],[Environment variables]appId,id,gg
```

* jobs
```
1. cd ansible/roles/install/jenkins
2. sudo tar -zxvf jobs.tar.gz -C /var/lib/jenkins
3. sudo chown -R develop:develop /var/lib/jenkins/jobs
4. jenkins,'Manage Jenkins','Reload Configuration from Disk'
```

* jobs
```
cd ansible/roles/install/jenkins
cwd=`pwd`
cd /var/lib/jenkins && tar -zcvf jobs.tar.gz jobs --exclude=builds --exclude=nextBuildNumber
mv jobs.tar.gz $cwd
```

* jenkins
```
sudo systemctl stop jenkins
sudo yum -y remove jenkins
sudo rm -rf /var/cache/jenkins
sudo rm -rf /var/lib/jenkins
sudo rm -rf /var/log/jenkins
```

* jenkins
```
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install -y jenkins
```
