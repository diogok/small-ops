# small ops

_EXPERIMENTAL_

Dead simple "devops" tools, on top of docker, etcd, confd and more.

## Installation

    gem install small-ops

## Tools

### fige

Inspired by [fig](http://orchardup.github.io/fig/), but simpler and more limited, as it is just a "fig run".

Follow the same [fig.yml](https://orchardup.github.io/fig/yml.html) format.

It can insert a "prefix" param on the name and env of the containers to run.

Usage:

    fige # will run the fig.yml containers, block on foreground and stop/rm the containers on ctrl+c/kill
    fige -d # will run the fig.yml containers and exit, leaving them running
    fige --prefix test # will run fig.yml, insert "prefix\_" on the names and the env the prefix on the "env"
    fige -t name # will run only the one named "name"

### docker2etcd

Register running containers to etcd, and an additional host and port, useful for service discovery using tools like confd.

Usage:

    docker2etcd # or
    docker2etcd --host localhost --etcd localhost:4001 --prefix 
  
All args are optional, default to machine ip (hostname -I | awk '{print $1}') as host and etcd on port 4001, prefix will put the containers on said prefix on etcd.

### etcd2env

Inject the etcd data on the env, as KEY\_SUBKEY=value. Usage:

    eval "$(etcd2env)" # or
    eval "$(etcd2env --prefix prefix --etcd localhost:4001)"

All args are optional, prefix is prefix key on etcd, etcd is the server.

### etcd2conf

Inspired by [confd](), but again simplified, as it just gets the data from etcd, pass in a specified erb template and write the new conf file, forever on each change (unless told otherwise).

Usage:

    etcd2conf -i nginx.conf.rb -o /etc/nginx/nginx.conf  -c 'nginx -s reload'

Arguments:

    -i Input template file
    -o Output file
    -d Run once only [optional]
    -c 'command' Execute 'command' after writting the config file [optional]

## License

MIT

