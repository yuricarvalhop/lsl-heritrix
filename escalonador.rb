require 'pry'
require_relative 'hashReader/model'

# escalonador
#
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

  def initialize config, crawl: nil
    DynWebStats.load_mongoid_config config

    @config = crawl ? Config.find(crawl) : Config.last
    @pages = []
    @crawl_list = []
  end

  def self.new_crawl config, capacity, info, seeds
    DynWebStats.load_mongoid_config config
    Config.create!(capacity: capacity, instant: 1,
                   info: info, seeds: seeds)


    # cria estrutura interna de coleta
    seeds.each do |s|
      @pages << {
        url: s,
        previous_collection_t: 0,
        next_crawl_t: 1
      }
    end

    # chama o run pra realizar o crawl
  end

  # gera estrutura interna de coleta a partir do db
  def get_pages_to_crawl
    t = @config.instant
    #crawl.last.pages.where(next_crawl_t: t)
  end

  # decide o que coletar
  def scheduler
    # ideal aqui eh ter uma função pra cada scheduler, ou uma classe
    # abstrata. Por enquanto vamos fazer um fifo
    @pages.sort!{|a,b| a[:previous_collection_t] <=> b[:previous_collection_t]}

    capacity = @config[:capacity]

    # verificar se capacidade eh menor ou maior
    @pages[capacity..-1].each do
      # postpone
    end

    @crawl_list = @pages[0..capacity]
  end

  def run
    # pega a estrutura interna, roda scheduler e gera arquivo de coleta
    # generate_crawl_file seeds, 1
  end

  # funções:
  #   start heritrix
  #   stop heritrix
  #   query heritrix to know it has finished
  #
  #   dado um array de páginas, cria a conf do heritrix
  #   filtra fixo gov.br

  def generate_crawl_file pages, instant
    f = File.open("#{instant}_seeds.txt", "w")
    pages.each{|p| f << p << "\n"}
    f.close
  end

  def self.load_mongoid_config config
    Mongoid.load!(config, :development)
  end
end

DynWebStats.new_crawl(ARGV[0], 1000, "olar", ["www.google.com"])
binding.pry

# primeira coleta   -> cria estrutura interna de coleta -> scheduler -> run -> pós processa resultado
# proximas coletas  -> pega dados do db e coloca na estrutura de coleta -> scheduler -> run -> pós processa resultado
