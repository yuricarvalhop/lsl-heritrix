#!/usr/bin/env ruby
require 'ruby-progressbar'
require 'pry'

MAX_THREADS = 24

def compress_warcs crawl_dir,dir_name
  files   = Dir["#{crawl_dir}/warcs/*"]
  #queue   = Queue.new
  #threads = []

  unless files[0] == nil
    #binding.pry

    #`gunzip #{files[0]}`          # Decompress gzip
    `touch #{crawl_dir}/warcs/universe`
    `mkdir #{crawl_dir}/warcs/0`          # Decompress gzip
    `gunzip -c #{crawl_dir}/warcs/*.gz | ../warc/./warc -t 50000000 -j -d 0 -p #{crawl_dir}/warcs `          # Decompress gzip
    `sort -u #{crawl_dir}/warcs/0/metadata -o #{crawl_dir}/warcs/0/metadata`          # Decompress gzip
    `iconv -f latin1 -t utf-8 #{crawl_dir}/warcs/0/resultados.json >> #{crawl_dir}/warcs/0/newResults.json`          # Decompress gzip
    `mv #{crawl_dir}/warcs/0/newResults.json #{crawl_dir}/warcs/0/resultados.json`          # Decompress gzip
    #nome = files[0].split('/')[7].gsub('.gz','')
    #`lzma -9 #{files[0].gsub('.gz','')}`  # Compress result using lzma
    #`mkdir #{file[0..-4]}/0`
    #`lzmadec #{files[0].gsub('.gz','')}.lzma | ../warc/./warc -t 50000000 -j -d 0 -p #{crawl_dir}/warcs`
    #`ruby ../hashReader/hashReader.rb`
    `ruby ../warc/hashReader/hashReader.rb #{crawl_dir}/warcs/0`
  end
  #threads << Thread.new do
  #  files.delete_if{ |file| file.split('.')[-1] == 'open' }.each do |file|
  #    queue << file
  #  end
  #  queue.close
  #end

  #progressbar = ProgressBar.create title: "Compressing", total: files.size, format: '%a [%B] %P%% %t'
  #binding.pry

  #1.upto(MAX_THREADS) do
  #  threads << Thread.new do
  #    while file = queue.pop
  #      if file.split('.')[-1] == 'gz'
  #        `gunzip #{file}`          # Decompress gzip
  #        `mkdir #{crawl_dir}/warcs/0`          # Decompress gzip
  #        `lzma -9 #{file[0..-4]}`  # Compress result using lzma
  #        #`mkdir #{file[0..-4]}/0`
  #        `lzmadec #{file[0..-4]}.lzma | ../warc/./warc -t 50000000 -j -d 0 -p #{crawl_dir}/warcs >> #{crawl_dir}/warcs/oi.json`
  #      else  # File was already decompressed
  #        `lzma -9 #{file}`
  #      end
  #      progressbar.increment
  #    end
  #  end
  #end

  #threads.each {|t| t.join}
end

#compress_warcs ARGV[0], ARGV[1]
