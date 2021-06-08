#!/bin/bash

##RUN as svn user. example
# su - svn -s /bin/bash
## or 
##RUN as root then changing onership recursively to svn user/group for project


#if home is correct, no need to prefix with absolute path
svnadmin create project1

#edit conf
#- disallow annonymous access
#- configure auth
#- set password database
sed -i -re 's/^(#.+)(anon-access = none|auth-access = write|password-db = passwd)/\2/g'  -e 's/^(#.+)(anon-access = ).+/\2none/g' project1/conf/svnserve.conf


#configure dummy user
echo "username1 = password1" >> project1/conf/passwd

