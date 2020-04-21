# quake3js

Run your own local QuakeJS.com server as a Docker container.

You can run it on your local x64 Linux based machine or even on your Raspberry Pi.

The provided image is open-source and built from scratch with the goal to
enable you to run a stateless and an immutable container,
according to the best practices.

Supported architectures:

* the image supports multiple architectures: `x86-64` and `arm32`
* the docker manifest is used for multi-platform awareness
* by simply pulling or running `ogivuk/quake3js:latest`, the correct image for your architecture will be retreived

| Tag | Transmission Version and Architecture |
| :--- | :----    |
| `:latest` | latest version (0.9) supporting both `x64` and `arm32v7` architectures |
| `:0.9` | version 0.9 supporting both `x64` and `arm32v7` architectures |
| `:0.9-x64` | version 0.9 for `x64` architecture |
| `:0.9-arm32v7` | version 0.9 for `arm32v7` architecture |

## Quick Start

1. _First time only_: Prepare the environment
    1. prepare a directory for the configurable files mounted to the container later:

        ```bash
        mkdir $HOME/quake3js
        cd $HOME/quake3js
        ```

    2. download the configurable files:

        ```bash
        wget https://github.com/ognjenvukovic/quake3js/blob/master/server.cfg
        wget https://github.com/ognjenvukovic/quake3js/blob/master/index.html
        ```

    3. edit `index.html` line 82 and replace `todo_change_me` in 2 places with the hostname or with your public IP address:
      * the hostname, where the server will be running, if the server needs to be only accessible within your local network.
      * your public IP address (or Domain Name), if you want the server to be also accessible from the public network. If the host is behind a router (in a local network), you also need to set up the port forwarding on your router for the ports `80` and `27960`.
      * this hostname or the IP address will be used later for accessing the server (port 80), e.g., for the hostname `myquake3js` it will be `http://myquake3js`

2. _Recommended_: Edit the server configuration

    * edit the `server.cfg` file to configure the server
    * it is **highly** recommended to change the default `rconpassword` as this password is used to remotely administer the server
    * all options in `server.cfg` as well as how to administer the server are explained below

3. Start the server
    * as a container:

        ```bash
        docker run -d \
            --name=quake3js \
            --restart unless-stopped \
            --publish 80:80 --publish 27960:27960 \
            --volume $(pwd)/server.cfg:/quakejs/base/baseq3/server.cfg \
            --volume $(pwd)/index.html:/var/www/html/index.html \
            ogivuk/quake3js
        ```

    * as a swarm service:

        ```bash
        docker service create \
            --name=quake3js \
            --publish=80:80 --publish=27960:27960 \
            --mount type=bind,src=$(pwd)/server.cfg,dst=/quakejs/base/baseq3/server.cfg \
            --mount type=bind,src=$(pwd)/index.html,dst=/var/www/html/index.html \
            ogivuk/quake3js
        ```

## Supporting Information

### Server.cfg

Here are explanations of the configuration options in `server.cfg`. The server needs to be restarted for the changes to take effect.

| Option | Explanation |
| :--- | :--- |
| sv_hostname "QuakeJS Server"| what players see on the join server window |
| seta sv_maxclients 12 | maximum number of players on the server |
| seta g_motd "Welcome to the Local baseq3 QuakeJS Server" | message players will see while joining the server |
| seta g_quadfactor 3 | quad Damage strength. 3 is normal, suggested 1 on Tourney servers |
| seta g_gametype 0 | sets the type of game: 0 - free for all, 1 - tournament, 2 - free for all(again), 3 - team Deathmatch, 4 - capture the flag |
| seta timelimit 15 | sets the timelimit in minutes |
| seta fraglimit 25 | sets the fraglimit |
| seta g_weaponrespawn 3 | number of seconds before weapons respawn |
| seta g_inactivity 3000 | number of seconds before an inactive player is kicked |
| seta g_forcerespawn 0 | forces players to respawn: 0 - off, 1 - on |
| seta rconpassword "quakejs" | sets the password to allow client control of the server |

The file ends with a few lines for setting up a map rotation, e.g.,:

```config
set d1 "map q3dm7 ; set nextmap vstr d2"
set d2 "map q3dm17 ; set nextmap vstr d1"
vstr d1
```

### In Game Player Commands

The following commands can be run by any player from its console, which can be accessed by typing `

| Command | Explanation |
| :-- | :-- |
| `/name ogi` | changes the player name to `ogi` |

### In Game Server Administration

The `rconpassword` from the `server.cfg` is needed for managing the server. The following commands can be run from the console, which can be accessed by typing `

| Command | Explanation |
| :-- | :-- |
| `/rconpassword [password]` | save locally the server password, replace `[password]` with the actual password in `server.cfg` |
| `/rcon map q3dm1` | changes the current map to `q3dm1` |
| `/rcon kick ogi` | kick the player `ogi` |
| `/rcon timelimit 10` | changes the timelimit to 10 minutes |

### Available Maps

The following maps are included in this image:

* q3dm1
* q3dm7
* q3dm17
* q3tourney2
* pro-q3tourney2

The following maps are included, but some textures are missing. They will work just fine, but they are not as visualy appealing due to the missing textures:

* q3dm9
* q3tourney6_ctf
* pro-q3dm6
* pro-q3dm13
* pro-q3tourney4

## Build your own image

For most users the provided image and the steps above will be enough. However, if for any reason you want to build your own image, here are the steps:

1. Clone the repository

    ```bash
    git clone https://github.com/ognjenvukovic/quake3js.git
    ```

2. Build from the Dockerfile:

    ```bash
    cd quake3js
    docker build -t ogivuk/quake3js .
    ```

3. Run post-built steps in a temporary container based on the image:
    * these steps are needed as a manual acceptance of the license is required
    * start a container and attach to its terminal

        ```bash
        docker run --name quake3js -it ogivuk/quake3js
        ```

    * while in the container, download BASE3Q files and accept the license (keep pressing ENTER to see it all)

        ```bash
        cd /quakejs
        node build/ioq3ded.js +set fs_game baseq3 +set dedicated 1

        ```

        * press `CTRL+C` once the terminal shows `ignoring setsockopt command`

    * while in the container, download CPMA files

        ```bash
        node build/ioq3ded.js +set fs_game cpma +set dedicated 1
        ```

        * press `CTRL+C` once the terminal shows `ignoring setsockopt command`

    * exit the container

        ```bash
        exit
        ```

    * copy the script for staring the server to the container

        ```bash
        docker cp start_server.sh quake3js:/
        ```

4. Commit the changes to the image and remove the temporary container

    ```bash
    docker commit \
        --change='ENTRYPOINT bash start_server.sh' \
        quake3js \
        ogivuk/quake3js
    docker rm quake3js
    ```

5. Now you can start the server using the Quick Start steps described above

## Links

* This Docker image and the guide are based on the instructions
[How to setup a local QuakeJS server](https://steamforge.net/wiki/index.php/How_to_setup_a_local_QuakeJS_server_under_Debian_9_or_Debian_10)
* [LVLWorld](https://lvlworld.com/) - a good source of additional maps
