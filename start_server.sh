#!/bin/bash

# redirect content.quakejs.com to localhost
# due to hardcoded content server address in the compiled ioq3 code
echo "127.0.0.1 content.quakejs.com" >> /etc/hosts

# start the apache server
/etc/init.d/apache2 start

# start the baseq3 server
cd /quakejs
node /quakejs/build/ioq3ded.js +set fs_game baseq3 set dedicated 1 +exec server.cfg
