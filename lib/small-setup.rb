
require 'uri'
require 'json'
require 'net/http'
require 'optparse'

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: command [options]"
  opts.on("-h", "--host host", "Set host IP/domain") do |h|
    options[:host] = h
  end
  opts.on("-e", "--etcd host:port", "Set etcd host and port") do |e|
    options[:etcd] = e
  end
  opts.on("-p", "--prefix prefix", "Set etcd prefix path") do |p|
    options[:prefix] = p
  end
  opts.on("-d","--daemon","Run in background") do |d|
    options[:daemon]=d
  end
  opts.on("-o","--output file","Output file") do |o|
    options[:output]=o
  end
  opts.on("-i","--input file","Input file") do |o|
    options[:input]=o
  end
  opts.on("-c","--command cmd","A command to execute at certain point") do |c|
    options[:cmd]=c
  end
  opts.on("-t","--target name","Target a single container") do |t|
      options[:target]=t
  end
  opts.on("-u","--as_url","Make url as host/name instead of host:port") do |u|
      options[:as_url]=u
  end
end.parse!


@host = options[:host] || ENV['HOST'] || `hostname -I | awk '{ print $1 }'`.gsub("\n","")
@etcd = options[:etcd] || ENV['ETCD'] || "http://#{@host}:4001"
@prefix = options[:prefix] || ENV['PREFIX'] || ""
@foreground = !options[:daemon]
@output = options[:output] || false
@input = options[:input] || false 
@cmd = options[:cmd] || false
@target = options[:target] || false
@as_url = options[:as_url] || false

def http_get(uri)
    JSON.parse(Net::HTTP.get(URI(uri)))
end

def http_put(uri,doc) 
    uri = URI.parse(uri)
    header = {'Content-Type'=> 'application/x-www-form-urlencoded'}
    if doc.class == Hash then
        header = {'Content-Type'=> 'application/json'}
    end
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Put.new(uri.request_uri, header)
    request.body = doc
    if doc.class == Hash then
        request.body=doc.to_json
    end
    response = http.request(request)
    if response.body.length >= 2 then
        JSON.parse(response.body)
    else
        {}
    end
end

def flatten(obj,sub)
    flat={}
    sub=sub.gsub("-","_").downcase
    obj.keys.each {|k|
        key=k.gsub("-","_").gsub("/","_").downcase
        if obj[k].class == Array then
            if(obj[k][0].class == Hash) then
                flat=flat.merge(flatten(obj[k][0],"#{sub}/#{k}"))
            end
        elsif obj[k].class == Hash then
            flat=flat.merge(flatten(obj[k],"#{sub}/#{k}"))
        else
            flat["#{sub}/#{key}"] = obj[k].to_s
        end
    }
    flat
end

def eflatten(obj)
  flat = {}
  if obj["dir"] then
    if obj["nodes"] then
      obj["nodes"].each { |n|
        flat = flat.merge(eflatten(n))
      }
    end
  else
    key = obj["key"].gsub("/","_").gsub("-","_")
    flat[key[1..key.length]]=obj["value"]
  end
  flat
end

def nodes2obj(nodes,prefix)
    obj={}
    nodes.each {|node|
      if node['dir'] && node['nodes'] then
        obj[node['key'].gsub(prefix,'')]=nodes2obj( node['nodes'],"#{ node['key'] }/" )
      elsif node['value'] then
        obj[node['key'].gsub(prefix,'')]=node['value']
      end
    }
    obj
end

