require 'pry'
require 'curses'
require 'active_support/all'

class RedBullAdventure
  attr_accessor :alert_level, :money

  def initialize
    @alert_level = rand 25..100
    @money       = rand 1..10
    @action_thread = Thread.new {}

    # Set up the display
    Curses.init_screen()
    Curses.curs_set 0
    Curses.stdscr.scrollok true
    init_display

  end

  def init_display

    default_window_options = {
      width: Curses.cols,
      height: 0,
      top: 0,
      left: 0,
      padding: {
        top: 0,
        right: 0,
        bottom: 0,
        left: 0
      }
    }

    @windows = {
      status_window: {
        options: {
          height: 3,
          top: 0,
          left: 0
        }
      },
      message_log_window: {
        options: {
          height: Curses.lines - 6,
          top: 3,
          left: 0
        }
      },
      input_window: {
        options: {
          height: 3,
          top: Curses.lines - 3,
          padding: {
            left: 2
          }
        }
      }
    }

    # Set up each of the window objects
    @windows.each do |name, win|

      win[:options].reverse_merge!(default_window_options)
      win[:options][:padding].reverse_merge!(default_window_options[:padding])

      container = Curses::Window.new(
        win[:options][:height],
        win[:options][:width],
        win[:options][:top],
        win[:options][:left]
      )

      container.box("|", "-")

      # Add the caret to the input window
      if name == :input_window
        container.setpos(1, 2)
        container.addstr(">")
      end

      container.refresh
      win[:container_window] = container

      inner_window = container.subwin(
        win[:options][:height] - 2,
        win[:options][:width] - 4 - win[:options][:padding][:left] - win[:options][:padding][:right],
        win[:options][:top] + 1,
        win[:options][:left] + 2 + win[:options][:padding][:left]
      )

      inner_window.scrollok true
      win[:inner_window] = inner_window

    end

  end

  def increment_money(num = 1)
    @money += num
    self
  end

  def increment_alert(num = 1)
    @alert_level += num
    self
  end

  def decrement_alert(num = 1)
    @alert_level -= num
    self
  end

  def set_alert(num)
    @alert_level = num
    self
  end

  def and
    self
  end

  def update_status(message)
    window = @windows[:status_window][:inner_window]
    window.addstr(message)
    window.refresh
    self
  end

  def update_log(message, delay_before: 0, delay_after: 2)
    sleep delay_before
    window = @windows[:message_log_window][:inner_window]
    window.addstr(message)
    window.refresh
    sleep delay_after
    self
  end

  def drink_red_bull
    update_log "You chug a Red Bull.\n", delay_before: 2
    @alert_level += rand 15..40
    update_log "Your pupils dilate as your heart rate speeds up and your senses become\nheightened from the massive amount of caffeine you have just ingested!\n"
    self
  end

  def fall_asleep
    "Sleep mode... ".chars.each do |char|
      update_log(char, delay_after: 0.1)
    end
    sleep 1
    "ACTIVATE!!!".chars.each do |char|
      update_log(char, delay_after: 0.1)
    end
    update_log "\n...while attempting to buy a Red Bull you fall asleep on the\npavement in front of the gas station...\n", delay_before: 2
    "Zzzz...".chars.each do |char|
      update_log(char, delay_after: 0.1)
    end
    set_alert(100).and.update_log("\nYou wake up 8 hours later feeling refreshed!\n", delay_before: 2)
    money_given = rand 1..10
    increment_money(money_given)
    update_log "You look around and realize people mistook you for a beggar and\nhave given you a total of $#{money_given}.00\n"
    self
  end

  def check_pocket_change
    update_log "\nYou go to the gas station to buy a Red Bull ($2.00)\n", delay_after: 0
    if @money >= 2
      @money -= 2
      drink_red_bull
    else
      update_log "You don't have enough money!\n", delay_before: 2
      fall_asleep
    end
    self
  end

  def handle_keyboard_input
    window = @windows[:input_window][:inner_window]
    command = window.getstr
    update_log "\nCommand Entered: #{command}\n", delay_after: 0
    if command == "exit" || command == "quit"
      stop_action_loop
    end
  end

  def start_action_loop
    @loop_running = true
    update_log "Your day begins...\n", delay_after: 0

    @action_thread = Thread.new do
      while @loop_running
        decrement_alert 5
        sleep 1
        if @alert_level < 20 && @alert_level > 10
          update_log "\rYou are coming down off of your caffeine high..."
        elsif @alert_level <= 10
          check_pocket_change
        end
      end
    end

    @update_status_thread = Thread.new do
      while @loop_running
        update_status "\rAlert Level: #{@alert_level} | Money: $#{@money}.00 "
        sleep 0.1
      end
    end

    @input_thread = Thread.new do
      while @loop_running
        handle_keyboard_input
      end
    end

    @update_status_thread.join
    @input_thread.join
    @action_thread.join
  end

  def stop_action_loop
    @loop_running = false
    @action_thread.kill
    @update_status_thread.kill
    @input_thread.kill
    system('clear')
  end

end

system('clear')
rba = RedBullAdventure.new
rba.start_action_loop
