FROM ubuntu:18.04

# Add the repository for Node.js and install
RUN apt-get update && apt-get install -y \
    curl

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt-get update && apt-get install -y \
    nodejs \
    git \
    nano \
    wget \
    apache2 \
    jq

# Clone the updated QuakeJS git repository
RUN git clone --recurse-submodules https://github.com/begleysm/quakejs.git

RUN cd quakejs && npm install

# Set Up a Local Content Server
## the script will grab all of the assets from http://content.quakejs.com and 
## put them where they can be accessed by clients
RUN cd /var/www/html/ \
 && wget https://steamforge.net/files/quakejs/get_assets.sh \
 && bash get_assets.sh \
 && rm get_assets.sh

# Set Up a Local Play Page (everything except the index.html)
RUN mkdir -p /var/www/html/css \
 && wget -O /var/www/html/css/game.css \
        http://www.quakejs.com/css/ff3bfe05fa66a6c5418f2f02b0e55e36-game.css \
 && mkdir -p /var/www/html/js \
 && wget -O /var/www/html/js/ioquake3.js \
        http://www.quakejs.com/js/38cbed8aa9a0bda4736d1aede69b4867-ioquake3.js \
 && wget -O /var/www/html/quakejs_favicons.tar.gz \
        http://steamforge.net/files/quakejs/quakejs_favicons.tar.gz \
 && tar -xvzf /var/www/html/quakejs_favicons.tar.gz \
        --directory /var/www/html/ \
 && rm /var/www/html/quakejs_favicons.tar.gz

ENTRYPOINT ["/bin/bash"]

# Required postbuilt:

# Download BASE3Q and CPMA files:
# cd /quakejs
# node build/ioq3ded.js +set fs_game baseq3 +set dedicated 1
# node build/ioq3ded.js +set fs_game cpma +set dedicated 1

# Redirect content.quakejs.com due to hardcoded content server address in the compiled ioq3 code
# echo "127.0.0.1 content.quakejs.com" >> /etc/hosts

# Start the apache server
# /etc/init.d/apache2 start

# Start the server
# node build/ioq3ded.js +set fs_game baseq3 set dedicated 1 +exec server.cfg

