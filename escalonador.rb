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
    Mongoid.load!(config, :development)
    @config = crawl ? Config.find(crawl) : Config.last
  end

  def self.new_crawl config, capacity, info, seeds
    Mongoid.load!(config, :development)
    Config.create!(capacity: capacity, instant: 1,
                   info: info, seeds: seeds)
    # colocar as seeds nas páginas
  end

  def run
    t = @config.instant
    crawl.last.pages.where(next_crawl_t: t)
  end

  # funções:
  #   start heritrix
  #   stop heritrix
  #   query heritrix to know it has finished
  #
  #   dado um array de páginas, cria a conf do heritrix
  #   filtra fixo gov.br



end

DynWebStats.new_crawl(ARGV[0], 1000, "olar", ["www.google.com"])
binding.pry
