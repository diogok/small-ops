# small ops

_EXPERIMENTAL_

Dead simple "devops" tools, on top of docker, etcd, confd and more.

## Installation

    apt-get install ruby
    gem install small-ops

## Tools

In general you can use the HOST env var for the tools, and the ETCD env var.

General parameters are:

    $ HOST=192.168.0.1 command
    $ command -h 192.168.0.1 # setup the host as relevant for the command
    $ ETCD=http://192.168.0.1:4001 command
    $ command -e http://192.168.0.1:4001 # setup the etcd server as relevant for the command

### fige

Run docker containers from a yml file, inspired by [fig](http://orchardup.github.io/fig/), but simpler and more limited, as it is just a "fig run".

Follow the same [fig.yml](https://orchardup.github.io/fig/yml.html) format.

It can insert a "prefix" param on the name and env of the containers to run.

Usage:

    $ fige # will run the fig.yml containers

Parameters:

    -c cmd, --command cmd : run "cmd" after each docker run
    -f, --foreground : keep fige on foreground and stop containers on exit
    -t name, --tagert name : only run specified container
    -i file, --input file : use "file" as yml
    -u, --update : pull container before run 

It will also insert HOST and ETCD into the container env.

### docker2etcd

Register running containers to etcd, and an additional host and port, useful for service discovery using tools like confd.

Usage:

    $ docker2etcd # register containers inspection and also URLs as HOST:PORT

Parameters:

    -u, --url : instead of registering URL as HOST:PORT register as HOST/NAME
    -v, --verbose : print all inserted data
    -c, --clear : Clear previous data of docker2etcd

### etcd2env

Inject the etcd data on the env, as KEY\_SUBKEY=value. Usage:

  
    $ etcd2env # print the result
    $ eval "$(etcd2env)" # eval the etcd data

### etcd2conf

Inspired by [confd](https://github.com/kelseyhightower/confd), but again simplified, as it just gets the data from etcd, pass in a specified erb template and write the new conf file, forever on each change (unless told otherwise).

Usage:

    $ etcd2conf -i nginx.conf.rb -o /etc/nginx/nginx.conf  -c 'nginx -s reload' -f

Arguments:

    -i file, --input file : Input template file
    -s template_String, --string template_string : Template as a raw string
    -o file, --output file : Output file
    -f, --foreground : Keep runing and watching changes
    -c 'command', --command 'command' : Execute 'command' after writting the config file

# log2stash

Logging to [logstash](http://logstash.net/) via syslog interface.

Usage:

  $ log2stash -i file.txt -f
  $ log2stash -m 'message to log ' 
  $ cat file | log2stash
  $ tail -f file | log2stash

Arguments:

  -i file, --input file : Input file to read and log
  -f, --foreground : Keep runing (use with file)
  -l host:port,  --logstash host:port : Host and Port of logstash, default to linked (if docker), to etcd (if available) and to localhost:9514
  -m message, --message msg : Message to log
  -n name, --name name : Name of the program (to identify in log)
  -p pri, --priority pri : Syslog priority of the log

## License

MIT

