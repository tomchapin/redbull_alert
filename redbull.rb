require 'pry'
require 'curses'

class RedBullAdventure
  attr_accessor :alert_level, :money

  def initialize
    @alert_level = rand 25..100
    @money       = rand 1..10
    @action_thread = Thread.new {}
  end

  def drink_red_bull
    puts "\nYou chug a Red Bull.\n"
    sleep 2
    puts "\nYour pupils dilate as your heart rate speeds\nup and your senses become heightened from the\nmassive amount of caffeine you have just ingested!\n"
    @alert_level += rand 15..40
  end

  def check_pocket_change
    if @money >= 2
      sleep 1
      puts "\nYou go to the gas station to buy a Red Bull.\n"
      @money -= 2
      sleep 2
      drink_red_bull
      sleep 2
    else
      sleep 2
      puts "\nYou go to the gas station to buy a Red Bull ($2.00).\n"
      sleep 2
      puts "\nYou don't have enough money!\n\n"
      sleep 2
      "sleep mode... ".chars.each do |char|
        print char
        sleep 0.1
      end
      sleep 1
      "ACTIVATE!!!".chars.each do |char|
        print char
        sleep 0.1
      end
      sleep 2
      puts "\n\n...while attempting to buy a Red Bull you fall asleep\non the pavement in front of the gas station...\n\n"
      sleep 2
      "Zzzz...".chars.each do |char|
        print char
        sleep 0.1
      end
      sleep 1
      puts "\n\nYou wake up 8 hours later feeling refreshed!\n"
      sleep 1
      @alert_level = 100
      money_given  = rand 1..10
      @money       += money_given
      puts "\nYou look around and realize people mistook you for a beggar and have given you a total of $#{money_given}.00\n"
      sleep 2
    end
  end

  def start_action_loop
    @loop_running = true
    @action_thread = Thread.new do
      while @loop_running
        @alert_level -= 5
        print "\rAlert Level: #{@alert_level} | Money: $#{@money}.00"
        sleep 1
        if @alert_level < 20
          puts "\n\nYou are coming down off of your caffeine high\nand your legs and arms feel like lead...\n"
          if @alert_level < 10
            check_pocket_change
          end
          puts "\n"
        end
      end
    end
    @action_thread.join
  end

  def stop_action_loop
    @loop_running = false
    @action_thread.kill
  end

end

system('clear')
rba = RedBullAdventure.new
rba.start_action_loop
