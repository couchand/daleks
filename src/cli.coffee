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
  constructor: (@character, @color) -> @dead = no
  show: ->
    return if @dead
    charm.position( @x, @y ).foreground( @color ).write @character
  die: -> @dead = yes
  moveLeft: -> @x = Math.max 1, @x-1
  moveDown: -> @y = Math.min rows-2, @y+1
  moveUp: -> @y = Math.max 1, @y-1
  moveRight: -> @x = Math.min cols, @x+1
  moveTowards: (other) ->
    return if @dead
    xd = @x - other.x
    yd = @y - other.y
    xda = Math.abs xd
    yda = Math.abs yd
    if yda > xda
      if yd > 0
        @moveUp()
      else if yd < 0
        @moveDown()
    else
      if xd > 0
        @moveLeft()
      else if xd < 0
        @moveRight()

random = (n) -> Math.floor Math.random() * n + 1
rr = -> random rows-2
rc = -> random cols

e = (ch, co) ->
  en = new Entity ch, co
  en.x = rc()
  en.y = rr()
  en

me = e '¤', 'cyan'
me.die = ->
  message 'Game over, you died :(', 'red'
  game_over = yes

entities = []

num_enemies = 4
for i in [0...num_enemies]
  entities.push e '¥', 'red'

checkForCollision = (left, right) ->
  if left.x is right.x and left.y is right.y
    left.die()
    right.die()
    wreckage = e '*', 'yellow', left.x, left.y
    wreckage.die = wreckage.moveTowards = ->
    entities.push wreckage

checkForCollisions = ->
  for i in [0...entities.length]
    checkForCollision me, entities[i]
    for j in [i+1...entities.length]
      checkForCollision entities[i], entities[j]

redraw = ->
  charm.erase 'screen'
  entity.show() for entity in entities
  me.show()
  show_message()
  charm.position( cols-1, rows-1 )

setInterval redraw, 100

game_over = no
exiting = no

do_exit = (chr) ->
  unless exiting
    exiting = yes
    message "#{chr} again to quit...",'cyan'
    return
  charm.reset()
  process.exit()

process.stdin.on 'data', (c) ->
  return do_exit 'q' if "#{c}" is 'q'
  if game_over
    switch "#{c}"
      when 'y' then restartGame()
      else do_exit 'q'
    return
  exiting = no
  switch "#{c}"
    when 'h' then me.moveLeft()
    when 'j' then me.moveDown()
    when 'k' then me.moveUp()
    when 'l' then me.moveRight()
  entity.moveTowards me for entity in entities
  checkForCollisions()

charm.removeAllListeners('^C')
charm.on '^C', ->
  message 'q to quit', 'red'
