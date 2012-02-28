require 'rubygems'
%w|core aggregates migrations|.map{|x| require "dm-#{x}"}
DataMapper.setup(:default, "sqlite:///#{Dir.pwd}/quotes.sqlite3")

class Quote
  include DataMapper::Resource

  property :id, Serial
  property :user, String, :key=>true
  property :date, Date, :writer=>:protected
  property :quote, Text
  belongs_to  :channel

  before :save do
    self.date=DateTime.new
  end

  # def self.random
  #   all.length > 0 ? (get(rand(all.length) + 1) || random) : nil
  # end
  def self.random
    if all.length>0
      repository.adapter.select "SELECT * FROM quotes ORDER BY RANDOM() LIMIT 1"
    else
      nil
    end
  end

  def self.random_with_custom value
    repository.adapter.select("SELECT * FROM quotes where quote LIKE ? OR user like ? ORDER BY RANDOM() LIMIT 1", value,value)
  end
  
end

class Channel
  include DataMapper::Resource

  property :id, Serial
  property :channel, String
  property :just_of_their_quotes, Boolean

  has n, :quotes

  def self.channels_list
    all(:fields=>[channel]).map{|n| n.channel}.join(',')
  end

end

DataMapper.finalize
DataMapper.auto_upgrade!
DataMapper.auto_migrate! unless File.exists?(File.join(Dir.pwd,"quotes.sqlite3"))
DataMapper::Logger.new("logs/queries.txt", :debug)
