#!/bin/bash

apt-get update
apt-get install -yqq subversion subversion-tools

BASE_PATH="/srv/svn/repos"

#create user and home directory
mkdir -p "$BASE_PATH"
adduser --system --group --home "$BASE_PATH" --no-create-home --disabled-login svn
chown -R svn:svn "$BASE_PATH"
#create logdirectory
mkdir /var/log/svnserve; 
chown svn /var/log/svnserve



#create systemd unit
cat > /etc/systemd/system/svnserve.service  <<'AAA'
[Unit]
Description=Subversion protocol daemon
After=syslog.target network.target

[Service]
Type=forking
RuntimeDirectory=svnserve
PIDFile=/run/svnserve/svnserve.pid
EnvironmentFile=/etc/default/svnserve
ExecStart=/usr/bin/svnserve $DAEMON_ARGS
User=svn
Group=svn
KillMode=control-group
Restart=on-failure

[Install]
WantedBy=multi-user.target
AAA

#create default config file
cat >/etc/default/svnserve <<BBB
# svnserve options
DAEMON_ARGS="--daemon --pid-file /run/svnserve/svnserve.pid --root $BASE_PATH --log-file /var/log/svnserve/svnserve.log"
BBB

##logrotate conf
cat >/etc/logrotate.d/svnserve <<'LOGROTATE'
/var/log/svnserve/*.log {
    daily
    missingok
    rotate 14
    compress
    notifempty
    create 640 svn adm
    sharedscripts
    postrotate
            if /bin/systemctl status svnserve > /dev/null ; then \
                /bin/systemctl restart svnserve > /dev/null; \
            fi;
    endscript
}
LOGROTATE

#refresh units
systemctl daemon-reload
systemctl enable svnserve.service
systemctl start svnserve.service


#create dummy repository
su - svn -s /bin/bash -c /vagrant/bootstrap_project.sh




