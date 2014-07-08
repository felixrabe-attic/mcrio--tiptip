#!/usr/bin/env coffee

ansi = require 'ansi'
stripAnsi = require 'strip-ansi'
keypress = require 'keypress'
getWindowSize = require './get-window-size'

position = 0
presentation = []
config = {}

clear = (cursor) ->
  # https://github.com/TooTallNate/ansi.js/blob/master/examples/clear/index.js
  cursor
  .write(Array.apply(null, Array(process.stdout.getWindowSize()[1])).map(-> '\n').join(''))
  .eraseData(2)
  .goto(1, 1)

exit = (cursor) ->
  clear cursor
  cursor.show()
  cursor.reset()
  cursor.write '\n'
  process.stdin.pause()

writeCenter = (cursor, content) ->
  getWindowSize (cols, rows) ->
    lines = content.trim().split('\n')
    y = Math.round((rows - lines.length) / 2) + 1
    clear cursor
    for line in lines
      x = Math.round((cols - (stripAnsi line).length) / 2) + 1
      cursor.goto x, y++
      cursor.write line
    cursor.goto 1, 1

writeTop = (cursor, content) ->
  lines = content.trim().split('\n')
  clear cursor
  x = Number(config.x ? 5)
  y = Number(config.y ? 2)
  for line in lines
    cursor.goto x, y++
    cursor.write line
  cursor.goto 1, 1

redrawed = 0
redraw = (cursor) ->
  [pos, content] = presentation[position]
  switch pos
    when 'center'
      writeCenter cursor, content
    else
      writeTop cursor, content

present = ->
  cursor = ansi(process.stdout)
  cursor.hide()
  clear cursor
  process.stdin.setRawMode true
  process.stdin.resume()

  keypress(process.stdin)
  process.stdin.on 'keypress', (char, key) ->
    switch key?.name
      when 'escape', 'q'
        exit cursor
      when 'l'  # redraw
        redraw cursor
      when 'left', 'up', 'backspace'
        prevPosition = position
        position = Math.max 0, position - 1
        redraw cursor unless prevPosition == position
      when 'right', 'down', 'space'
        prevPosition = position
        position = Math.min presentation.length - 1, position + 1
        redraw cursor unless prevPosition == position

  redraw cursor

setImmediate -> present() if presentation.length > 0

module.exports = tiptip =
  config: (config_) ->
    config = config_
    tiptip
  center: (s) ->
    presentation.push ['center', s]
    tiptip
  lines: (s) ->
    lines = s.trim().split('\n')
    content = []
    for line in lines
      content.push line
      presentation.push ['top', content.join('\n')]
    tiptip
