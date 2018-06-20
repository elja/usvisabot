#!/usr/bin/env ruby

require 'usbot'
require 'telegram/bot'

class USBot
  TELEGRAM_TOKEN = "598842162:AAHDNTSqHmNI513OIMKWQW2fFtDgXrhC7b4"

  def start!
    Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
      bot.listen do |message|
        case message.text
        when /\/start/
          start_scheduler!(bot, message)
        when /\/stop/
          stop_scheduler!
        when /\/refresh/
          Thread.new { print_dates(bot, message) }
        end
      end
    end
  end

  private

  def print_dates(bot, message)
    scraper = HTMLScraper.new
    dates = scraper.scrap!

    dates.each_with_index do |(month, dates), index|
      if dates[:available].any?
        msg = "Dates for #{month}:\n\n"
        msg += dates[:available].join("\n")

        if index == 0
          10.times do
            bot.api.send_message(chat_id: message.chat.id, text: "!!!!!")
            bot.api.send_message(chat_id: message.chat.id, text: msg)
            bot.api.send_message(chat_id: message.chat.id, text: "!!!!!")
          end
        else
          bot.api.send_message(chat_id: message.chat.id, text: msg)
        end
      else
        msg = "Dates for #{month}:\n\n"
        msg += "No dates available.."

        bot.api.send_message(chat_id: message.chat.id, text: msg)
      end
    end
  end

  def stop_scheduler!
    scheduler.stop
    @scheduler = nil
  end

  def start_scheduler!(bot, message)
    stop_scheduler! if scheduler.up?

    scheduler.every '1m' do
      print_dates(bot, message)
    end
  end

  def scheduler
    @scheduler ||= Rufus::Scheduler.new
  end
end

bot = USBot.new
bot.start!
