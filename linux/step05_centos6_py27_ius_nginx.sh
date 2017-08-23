#!/bin/bash
OMEROVER=${OMEROVER:-latest}
ICEVER=${ICEVER:-ice36}


set -e -u -x

#start-copy
cp setup_omero_nginx.sh ~omero
#end-copy

p=nginx

if [ "$ICEVER" = "ice36" ]; then
#web-requirements-recommended-start
	file=~omero/OMERO.server/share/web/requirements-py27-all.txt
#web-requirements-recommended-end
else
#web-requirements-ice35-start
	file=~omero/OMERO.server/share/web/requirements-py27-all-ice35.txt
#web-requirements-ice35-end
fi

#start-install
cat << EOF > /etc/yum.repos.d/nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=0
enabled=1
EOF



#install nginx
yum -y install nginx

virtualenv -p /usr/bin/python2.7 /home/omero/omeroenv
set +u
source /home/omero/omeroenv/bin/activate
set -u


#start-latest
/home/omero/omeroenv/bin/pip2.7 install -r $file
#end-latest
deactivate

# set up as the omero user.
su - omero -c "bash -eux setup_omero_nginx.sh nginx"

#end-install
mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.disabled
cp ~omero/OMERO.server/nginx.conf.tmp /etc/nginx/conf.d/omero-web.conf

service nginx start