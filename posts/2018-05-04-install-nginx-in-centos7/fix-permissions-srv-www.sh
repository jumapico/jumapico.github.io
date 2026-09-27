#!/bin/bash
#
# Fix file permissions for directory `/srv/www`:
#
# * Modify acl's for files to give acces to nginx user.
# * Restore selinux context for files
#
set -e
set -x

echo '`Fix file permissions in /srv/www`'
setfacl -R -m u:nginx:rx /srv/www
restorecon -R /srv/www

echo 'Done'
