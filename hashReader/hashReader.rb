require 'mongoid'
require 'json'
require 'pry'
require_relative 'model'

Mongoid.load! "../warc/hashReader/mongoid.yml", :migration
Mongoid.raise_not_found_error = false

crawl_dir = ARGV[0]

lista_paginas = []
lista_coletas = []
#metadata = File.read('../teste/0/oi/universe').split("\n")
#hash = File.read('../bla.json').split("\n")

metadata = File.read("#{crawl_dir}/metadata").split("\n")
hash = File.read("#{crawl_dir}/resultados.json").split("\n")
#Fazer isso aq pra n subir 10 gb pra ram
#File.open('../bla.json').each_line do |line|
#
#end

metadata.each do |key|
  page = {"url": key}
  lista_paginas << page
end
Page.collection.insert_many(lista_paginas, {ordered: false})

hash.each do |key|
  parsed_json = JSON.parse(key)

  coleta = {
    "content": parsed_json["content"],
    "url": parsed_json["WARC-Target-URI"],
    "warc_date": parsed_json["WARC-Date"],
    "payload_digest": parsed_json["WARC-Payload-Digest"],
    "ip_address": parsed_json["WARC-IP-Address"],
    "record_id": parsed_json["WARC-Record-ID"],
    "content_type":  parsed_json["Content-Type"],
    "content_length": parsed_json["Content-Length"],
    "protocol": parsed_json["protocol"],
    "code": parsed_json["code"],
    "date": parsed_json["Date"],
    "location": parsed_json["Location"],
    "connection": parsed_json["Connection"]
  }
  lista_coletas << coleta
end
Crawl.collection.insert_many(lista_coletas)
