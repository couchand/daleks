# daleks cli

charm = require('charm')(process)
charm.reset()
charm.cursor(false)

cols = process.stdout.columns
rows = process.stdout.rows

current_message = ''
message_color = 'cyan'

message = (str, col) ->
  current_message = str if str
  message_color = col if col?

show_message = ->
  charm.position(0, rows).foreground(message_color).write(current_message)

class Entity
  constructor: (@character, @color) ->
  show: ->
    charm.position( @x, @y ).foreground( @color ).write @character
  moveLeft: -> @x = Math.max 1, @x-1
  moveDown: -> @y = Math.min rows-2, @y+1
  moveUp: -> @y = Math.max 1, @y-1
  moveRight: -> @x = Math.min cols, @x+1

e = (ch, co, x, y) ->
  en = new Entity ch, co
  en.x = x
  en.y = y
  en

me = e '¤', 'cyan', 15, 15
entities = [
  e '¥', 'red', 7, 5
  e '¥', 'red', 1, 15
  e '¥', 'red', 27, 25
  e '¥', 'red', 14, 17
  me
]

setInterval( (->
  charm.erase 'screen'
  entity.show() for entity in entities
  show_message()
  charm.position( cols-1, rows-1 )
), 100)

exiting = no

exit = (chr) ->
  unless exiting
    exiting = yes
    message "#{chr} again to quit...",'cyan'
    return
  charm.reset()
  process.exit()

process.stdin.on 'data', (c) ->
  return exit 'q' if "#{c}" is 'q'
  exiting = no
  switch "#{c}"
    when 'h' then me.moveLeft()
    when 'j' then me.moveDown()
    when 'k' then me.moveUp()
    when 'l' then me.moveRight()

charm.removeAllListeners('^C')
charm.on '^C', ->
  message 'q to quit', 'red'
