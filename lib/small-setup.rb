
require 'uri'
require 'json'
require 'net/http'
require 'optparse'

@options = {}
if ENV["HOST"] then
  @options[:host] = ENV["HOST"]
else
  @options[:host] = `hostname -I | awk '{ print $1 }'`.gsub("\n","")
end

if ENV["ETCD_PORT_4001_TCP_ADDR"] then
    @options[:etcd] = "http://#{ENV["ETCD_PORT_4001_TCP_ADDR"]}:#{ENV["ETCD_PORT_4001_TCP_PORT"]}"
else
    @options[:etcd] = ENV['ETCD'] || "http://#{@options[:host]}:4001"
end

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

def http_delete(uri)
  uri = URI.parse(uri)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Delete.new(uri.request_uri)
  response = http.request(request)
  JSON.parse(response.body)
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

