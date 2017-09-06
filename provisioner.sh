#!/bin/bash

DIR=`dirname $0`
PROJECT_ROOT="/var/www/html"

function timer()
{
    if [[ $# -eq 0 ]]; then
        echo $(date '+%s')
    else
        local  stime=$1
        etime=$(date '+%s')

        if [[ -z "$stime" ]]; then stime=$etime; fi

        dt=$((etime - stime))
        ds=$((dt % 60))
        dm=$(((dt / 60) % 60))
        dh=$((dt / 3600))
        printf '%d:%02d:%02d' $dh $dm $ds
    fi
}

startTime=$(timer)
echo "$(date) Starting now...:"

t=$(timer)
echo
echo
echo "****************************************************"
echo "**** Adding the needed keys and repositories... ****"
echo "****************************************************"
wget -P /tmp/ http://nginx.org/keys/nginx_signing.key
apt-key add /tmp/nginx_signing.key
add-apt-repository ppa:ondrej/php --yes
printf 'DONE    ...    Elapsed time: %s \n\n' $(timer $t)

t=$(timer)
echo
echo
echo "**********************************"
echo "**** Updating repositories... ****"
echo "**********************************"
apt-get update -qq
printf 'DONE    ...    Elapsed time: %s \n\n' $(timer $t)

t=$(timer)
echo
echo
echo "*********************************************"
echo "**** Removing unecessary dependencies... ****"
echo "*********************************************"
apt-get autoremove -q
printf 'DONE    ...    Elapsed time: %s \n\n' $(timer $t)

t=$(timer)
echo
echo
echo "*******************************************"
echo "**** Installing NGINX and PHP packages ****"
echo "*******************************************"
packages=("nginx" "php7.0" "php7.0-common" "php7.0-cli" "php7.0-cgi" "php7.0-curl" "php7.0-gd" "php7.0-zip" "php7.0-dom" "php7.0-mbstring" "php7.0-mysql" "php7.0-fpm");
for pkg in "${packages[@]}"; do
    isInstalled=$(which $pkg 2>/dev/null | grep -v "not found" | wc -l)
    if [ $isInstalled -eq 0 ] ; then
        t=$(timer)
        echo
        echo
        echo "**** Installing $pkg...  ****"
        apt-get install -qq --force-yes --yes $pkg
        printf 'DONE    ...    Elapsed time: %s \n\n' $(timer $t)
    else
        echo ">>> $pkg is already installed"
    fi
done

t=$(timer)
echo
echo
echo "******************************"
echo "**** Configuring NGINX... ****"
echo "******************************"
cp $DIR/nginx.conf /etc/nginx/nginx.conf
cp $DIR/koel.conf /etc/nginx/conf.d
printf 'DONE    ...    Elapsed time: %s \n\n' $(timer $t)

t=$(timer)
echo
echo
echo "****************************************************"
echo "**** Restarting and reloading NGINX and PHP-FPM ****"
echo "****************************************************"
service nginx reload
service nginx restart
service php7.0-fpm restart
printf 'DONE    ...    Elapsed time: %s \n\n' $(timer $t)

echo "\n\n\n"
echo "********************************"
echo "**** Finished provisioning! ****"
echo "********************************"

printf 'Total Elapsed time: %s\n' $(timer $startTime)

echo "$(date) End."