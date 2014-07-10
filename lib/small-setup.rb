
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
  opts.on("-d","--daemon","what") do |d|
    options[:daemon]=d
  end
end.parse!

@host = options[:host] || ENV['HOST'] || `hostname -I | awk '{ print $1 }'`.gsub("\n","")
@etcd = options[:etcd] || ENV['ETCD'] || "http://#{@host}:4001"
@prefix = options[:prefix] || ENV['PREFIX'] || ""
@foreground = !options[:daemon] || true

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

