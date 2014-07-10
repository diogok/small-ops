Gem::Specification.new do |s|
    s.name        = "small-ops"
    s.version     = "0.0.1.pre"
    s.date        = "2014-07-09"
    s.summary     = "Small Docker ops utils"
    s.description = "Docker, etcd, confd..."
    s.authors     = ["Diogo Silva"]
    s.email       = "diogo@diogok.net"
    s.files       = ["lib/small-setup.rb"]
    s.executables = ["docker2etcd","etcd2env"]
    s.homepage    = "https://github.com/" 
    s.license	  = "MIT"
end
