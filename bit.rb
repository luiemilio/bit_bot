require 'byebug'
require 'telegram/bot'
require 'excon'
require 'json'
require_relative 'token'

def get_data(coin)
  coin == 'all' ? get_all_coins : get_coin(coin)
end

def get_all_coins
  response = Excon.get('https://api.coinmarketcap.com/v1/ticker/?limit=10')
  data = ''
  JSON.parse(response.body).each do |coin|
    data += "#{coin["name"]}: #{coin["price_usd"]} USD\n"
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
  Telegram::Bot::Client.run(token) do |bot|
    bot.listen do |message|
      case message.text
      when '/btc'
        bot.api.send_message(chat_id: message.chat.id, text: get_data("bitcoin"))
      when '/ltc'
        bot.api.send_message(chat_id: message.chat.id, text: get_data("litecoin"))
      when '/eth'
        bot.api.send_message(chat_id: message.chat.id, text: get_data("ethereum"))
      when '/xrp'
        bot.api.send_message(chat_id: message.chat.id, text: get_data("ripple"))
      when '/all'
        bot.api.send_message(chat_id: message.chat.id, text: get_data("all"))
      end
    end
  end
end

run_bot
