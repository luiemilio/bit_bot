require 'byebug'
require 'telegram/bot'
require 'excon'
require 'json'
require_relative 'token'

def get_all_coin_symbols
  response = Excon.get('https://api.coinmarketcap.com/v1/ticker/')
  coin_hash = {}
  JSON.parse(response.body).each do |coin|
    coin_hash[coin["symbol"]] = coin["id"] 
  end
  coin_hash
end

def get_data(coin)
  coin == 'all' ? get_all_coins : get_coin(coin)
end

def get_all_coins
  response = Excon.get('https://api.coinmarketcap.com/v1/ticker/?limit=10')
  data = "Top 10 Coins on coinmarketcap.com\n"
  JSON.parse(response.body).each do |coin|
    data += "#{coin["rank"]} - #{coin["name"]}: #{coin["price_usd"]} USD\n"
  end
  data
end

def get_coin(coin)
  response = Excon.get("https://api.coinmarketcap.com/v1/ticker/#{coin}/")
  coin_data = JSON.parse(response.body)[0]
  "#{coin_data["name"]}
  USD: #{coin_data["price_usd"]}
  BTC: #{coin_data["price_btc"]}
  1h: #{coin_data["percent_change_1h"]}%
  24h: #{coin_data["percent_change_24h"]}%
  7d: #{coin_data["percent_change_7d"]}%"
end

def run_bot
  token = KEY
  all_coin_symbols = get_all_coin_symbols
  Telegram::Bot::Client.run(token) do |bot|
    bot.listen do |message|
      coin_sym = message.text[1..-1].upcase
      case message.text[0]
      when '/'
        if all_coin_symbols.keys.include?(coin_sym)
          coin_name = all_coin_symbols[coin_sym]
          bot.api.send_message(chat_id: message.chat.id, text: get_data(coin_name))
        elsif coin_sym == 'ALL'
          bot.api.send_message(chat_id: message.chat.id, text: get_data("all"))
        end
      end
    end
  end
end

run_bot


