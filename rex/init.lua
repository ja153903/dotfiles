-- Rex config. Edit, then `rex config reload`. Actions: `rex -C jimmy actions`.

-- Splits (alt+p prefix, same as ghostty)
rex.bind("alt+p>n", "pane.split.right")
rex.bind("alt+p>shift+n", "pane.split.left")
rex.bind("alt+p>d", "pane.split.down")
rex.bind("alt+p>shift+d", "pane.split.up")
rex.bind("alt+p>z", "pane.zoom")
rex.bind("alt+p>x", "pane.close")

-- Resize mode: alt+r, then hjkl repeatedly, = to balance, escape to leave
rex.mode("resize", { exclusive = true })
rex.bind("alt+r", "client.mode.enter", { name = "resize" })
rex.bind("resize/h", "pane.resize", { direction = "left" })
rex.bind("resize/j", "pane.resize", { direction = "down" })
rex.bind("resize/k", "pane.resize", { direction = "up" })
rex.bind("resize/l", "pane.resize", { direction = "right" })
rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")

-- Tabs
rex.bind("alt+t>l", "client.tab.next")
rex.bind("alt+t>h", "client.tab.previous")
rex.bind("alt+t>n", "client.tab.new")

-- Sessions
rex.bind("alt+s>l", "session.next")
rex.bind("alt+s>h", "session.previous")
rex.bind("alt+s>s", "session.switch")
rex.bind("alt+s>n", "session.new")

-- Pane focus
rex.bind("alt+h", "pane.focus.left")
rex.bind("alt+j", "pane.focus.down")
rex.bind("alt+k", "pane.focus.up")
rex.bind("alt+l", "pane.focus.right")
