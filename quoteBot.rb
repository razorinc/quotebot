require 'rubygems'
require 'isaac'
require 'database'


configure do |c|
  c.server = "an.irc.server.com"
  c.port = 6667
  c.realname = "QuoteBot"
  c.nick = "QuoteBot"
end

on :connect do
  # take stuff from db
  join Channel.channels_list unless Channel.all.size==0
  join "#quotebot-test-channel" if Channel.all.length==0
end

on :private,/^\!join (.*)$/  do |channel_to_join|
  if channel_to_join[/\#/]
    join channel_to_join
    Channel::first_or_create(:channel=>channel_to_join)
  else
    msg nick, "Sorry i can't join your channel"
  end
end

on :channel, /^\!quote$/ do
  quote = Quote.random
  if quote.nil?
    msg channel, "No quotes"
  else
    msg channel,quote.first.quote
  end
end

on :channel, /^\!source$/ do
  msg channel, "My source is at http://github.com/razorinc/quotebot"
end

on :kick do
  sleep rand(5)
  join Channel::channels_list
end

on :channel, /^\!quote \*(.*)\*$/ do |contains|
  quote = Quote.random_with_custom "%#{contains}%"
  if (quote.nil? or quote.empty? )
    msg channel, "No quotes"
  else
    msg channel, quote.first.quote
  end
end


on :channel, /^!quote add (.*?)$/ do |quoted_message|
  quote=Quote::create(:user=>nick,:quote=>quoted_message)
  #should always work #first_or_create
  quote.channel=Channel.first_or_create(:channel=>channel)
  quote.save
  if quote.saved?
#    msg channel, "Quote added!"
    raw ["NOTICE #{user} :", "Quote added"].join
  else
    msg channel, "Quote not added!"
  end
end
