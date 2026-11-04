-- Rex config. Edit, then `rex config reload`. Actions: `rex -C jimmy actions`.

-- Splits (cmd+p prefix)
rex.bind("cmd+p>n", "pane.split.right")
rex.bind("cmd+p>shift+n", "pane.split.left")
rex.bind("cmd+p>d", "pane.split.down")
rex.bind("cmd+p>shift+d", "pane.split.up")
rex.bind("cmd+p>z", "pane.zoom")
rex.bind("cmd+p>x", "pane.close")

-- Resize mode: cmd+r, then hjkl repeatedly, = to balance, escape to leave
rex.mode("resize", { exclusive = true })
rex.bind("cmd+r", "client.mode.enter", { name = "resize" })
rex.bind("resize/h", "pane.resize", { direction = "left" })
rex.bind("resize/j", "pane.resize", { direction = "down" })
rex.bind("resize/k", "pane.resize", { direction = "up" })
rex.bind("resize/l", "pane.resize", { direction = "right" })
rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")

-- Sessions
rex.bind("cmd+s>l", "session.next")
rex.bind("cmd+s>h", "session.previous")
rex.bind("cmd+s>s", "session.switch")
rex.bind("cmd+s>n", "session.new")

-- Pane focus
rex.bind("cmd+p>h", "pane.focus.left")
rex.bind("cmd+p>j", "pane.focus.down")
rex.bind("cmd+p>k", "pane.focus.up")
rex.bind("cmd+p>l", "pane.focus.right")
