Gem::Specification.new do |s|
    s.name        = "small-ops"
    s.version     = "0.0.42"
    s.date        = "2014-07-09"
    s.summary     = "Small Docker ops utils"
    s.description = "Docker, etcd, confd, fig..."
    s.authors     = ["Diogo Silva"]
    s.email       = "diogo@diogok.net"
    s.files       = ["lib/small-setup.rb"]
    s.executables = ["docker2etcd","etcd2env","etcd2conf","fige","log2stash"]
    s.homepage    = "https://github.com/" 
    s.license	  = "MIT"
end
