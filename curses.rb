require 'curses'

Curses.init_screen()

Curses.stdscr.scrollok true

status_window = {
  width: 70,
  height: 20,
  top: 0,
  left: 0
}

bwin = Curses::Window.new(status_window[:height], status_window[:width], status_window[:top], status_window[:left])
bwin.box("|", "-")
bwin.refresh

win = bwin.subwin(status_window[:height]-2, status_window[:width]-2, status_window[:top]+1, status_window[:left]+1)

win.scrollok true

while TRUE
  win.addstr("#{Time.now.to_s} - This is a test message. The quick brown fox jumped over the lazy dog. \n")
  win.refresh
  sleep 1
end

#win.getch
#win.close