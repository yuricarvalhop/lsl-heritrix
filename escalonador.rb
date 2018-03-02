require 'pry'
require_relative 'hashReader/model'
require_relative 'heritrix'
require_relative 'warc'
require_relative 'fifo'

# escalonador
# 1. instanciar variáveis iniciais (qual o T, qual a capacidade C, etc)
# 2. busca no banco as páginas agendadas para T
# 3. verifica se ultrapassa a capacidade C
# 4. caso sim: temos que postergar páginas -> usamos política de escalonamento
# 5. caso não: vemos se tem páginas postergadas e adiantamos sua coleta
# 6. coleta as páginas
# 7. após coleta, processa indicadores, atualiza banco com dados de mudança e novas datas de agendamento
#
# as busca no banco já retornam os dados corretamente.
# O yuri já fez as partes de processamento (extração de links e mudança de páginas)
#
# entrada (vem do db)
# saida atualização do banco
# saida eh uma lista de urls que serão coletadas

class DynWebStats
  def self.new_config mongoid_config, capacity, info, seeds
    DynWebStats.load_mongoid_config mongoid_config
    config = Config.create!(capacity: capacity, instant: 1, info: info, seeds: seeds)

    # coloca as seeds no fluxo normal de coleta
    seeds.each do |seed|
      Page.create(url: seed, previous_collection_t: 0, next_crawl_t: 1, config: config)
    end
  end

  def initialize mongoid_config, job_name: "mapaweb", sched: :fifo, config:
    DynWebStats.load_mongoid_config mongoid_config

    @config = config ? config : Config.last
    @pages = []
    @crawl_list = []
    @path = Dir.pwd
    @job_name = job_name
    @heritrix = Heritrix.new(@path, @job_name)
    @warc_path = "#{@path}/jobs/#{@job_name}/warcs/latest"

    case sched
    when :fifo
      @scheduler = Fifo
    when :lifo
      @scheduler = Lifo
    else
      raise "Invalid scheduler"
    end
  end

  def run
    create_crawl
    get_pages_to_crawl
    scheduler
    @heritrix.update_seeds(@pages.pluck(:url))
    @heritrix.start
    #TODO WAIT
    @heritrix.run_job
    #TODO WAIT
    @heritrix.stop
    #TODO WAIT
    parse_warcs

    process_pages
    # update mongo(next_collection, previous_collect)
    # pega a estrutura interna, roda scheduler e gera arquivo de coleta
  end

  def process_pages
    lista = []

    #db.paginas.createIndex({"url": 1}, { unique: true})
    File.read("#{@warc_path}/0/metadata").each_line do |line|
      lista << { url: line.chomp, previous_collection_t: @scheduler.priority, next_crawl_t: @config.instant + 1, config: @config }
    end

    begin
      Page.collection.insert_many(lista_paginas, { ordered: false })
    rescue Mongo::Error::BulkWriteError # Existing pages
    end
  end

  def parse_warcs
    Warc.parse(@warc_path)
  end

  def create_crawl
    @crawl = Crawl.create!(collection_t: @config.instant, config: @config)
  end

  # gera estrutura interna de coleta a partir do db
  def get_pages_to_crawl
    @pages = @config.pages.where(next_crawl_t: @config.instant)
  end

  # decide o que coletar
  def scheduler
    capacity = @config[:capacity]

    @crawl_list, @remainer = @scheduler.sched(@pages, capacity)

    if @remainer.any?
      @remainer.update_attribute(:postpone, true)
    else
      postponed = @crawl.pages.where(postpone: true)
      @postponed_list, _ = @scheduler.sched(postponed, capacity - @crawl_list.size)
    end

    #TODO otimizar
    @pages = @crawl_list + @postponed_list
    @crawl.pages = @pages
  end

  def self.load_mongoid_config config
    Mongoid.load!(config, :development)
  end
end

if ARGV.size != 1
  puts "Usage: ruby escalonador.rb mongo_config"
  exit -1
end

#config = DynWebStats.new_config(ARGV[0], 1000, "olar", ["www.agricultura.gov.br"])
dws = DynWebStats.new(ARGV[0], config: nil)
dws.run
binding.pry

# primeira coleta  -> cria estrutura interna de coleta -> scheduler -> run -> pós processa resultado
# proximas coletas -> pega dados do db e coloca na estrutura de coleta -> scheduler -> run -> pós processa resultado
