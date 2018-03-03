require 'mongoid'

class Crawl
  include Mongoid::Document
  #include Mongoid::Attributes::Dynamic
  store_in collection: "coletas"
  belongs_to :config

  has_and_belongs_to_many :pages
  #field :crawl_id,       type: Integer
  #field :pagina_id,      type: String
  #field :warc_date,      type: Time,    default: ->{ Time.now }
  #field :payload_digest, type: String
  #field :ip_address,     type: String
  #field :record_id,      type: String
  #field :content_type,   type: String
  #field :content_length, type: Integer
  #field :protocol,       type: String
  #field :code,           type: String
  #field :date,           type: Time
  #field :location,       type: String
  #field :connection,     type: String
  field :collection_t,   type: Integer

  #def timed_out?
  #  Time.now - self.start >= $config['time_limit']
  #  #false
  #end
end

class Page
  include Mongoid::Document
  #include Mongoid::Attributes::Dynamic
  store_in collection: "paginas"

  has_and_belongs_to_many :crawls
  belongs_to :config

  field :url,                   type: String
  field :content,               type: String
  field :distance,              type: Float,   default: nil
  field :size,                  type: Array,   default: []
  field :crawl_status,          type: Integer, default: 0
  field :previous_collection_t, type: Integer
  field :next_collection_t,     type: Integer

  def request_success?
    !self.status.nil? && (self.status.between?(200, 299) || self.status.between?(300, 399))  # Code 2XX ||| 3XX
  end

end

class Config
  include Mongoid::Document

  has_many :crawls
  has_many :pages

  field :capacity,    type: Integer
  field :instant,     type: Integer
  field :info,        type: String
  field :seeds,       type: Array, default: []
end

