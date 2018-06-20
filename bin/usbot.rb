#!/usr/bin/env ruby

require './lib/usbot'
require 'telegram/bot'

class USBot
  TELEGRAM_TOKEN = "598842162:AAHDNTSqHmNI513OIMKWQW2fFtDgXrhC7b4"

  def initialize(appointment_date:)
    @appointment_date = Date.parse(appointment_date)
  end

  def start!
    Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
      bot.listen do |message|
        case message.text
        when /\/start/
          start_scheduler!(bot, message)
        when /\/stop/
          stop_scheduler!
        when /\/refresh/
          print_dates(bot, message)
        end
      end
    end
  end

  private

  def print_dates(bot, message)
    scraper = HTMLScraper.new
    dates = scraper.scrap!

    below_msg = "Dates Below Appointment (#{format_date(@appointment_date)}):\n\n"
    above_msg = "Dates Above Appointment (#{format_date(@appointment_date)}):\n\n"

    dates_below = []
    dates_above = []

    dates.keys.each do |date|
      next if date.monday?

      if date < @appointment_date
        dates_below << date
      else
        dates_above << date
      end
    end

    if dates_below.any?
      dates_below.each { |d| below_msg += date_str(d, dates[d]) }

      10.times do
        bot.api.send_message(chat_id: message.chat.id, text: "!!!!!!!!!!!!!!!!!!!!!!!\n")
        bot.api.send_message(chat_id: message.chat.id, text: below_msg)
        bot.api.send_message(chat_id: message.chat.id, text: "!!!!!!!!!!!!!!!!!!!!!!!\n")
      end
    else
      below_msg += "There is no available dates..."
      bot.api.send_message(chat_id: message.chat.id, text: below_msg)
    end

    if dates_above.any?
      dates_above.each { |d| above_msg += date_str(d, dates[d]) }
      bot.api.send_message(chat_id: message.chat.id, text: above_msg)
    else
      above_msg += "There is no available dates..."
      bot.api.send_message(chat_id: message.chat.id, text: above_msg)
    end
  end

  def date_str(date, available)
    "#{format_date(date)}: #{available}\n"
  end

  def format_date(date)
    date.strftime('%d %B %Y')
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

bot = USBot.new(appointment_date: ARGV[0])
bot.start!
