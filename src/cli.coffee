# daleks cli

charm = require('charm')(process)
charm.reset()
charm.cursor(false)

cols = process.stdout.columns
rows = process.stdout.rows

message = (str, col) ->
  charm.position(0, rows).foreground(col).write(str)

class Entity
  constructor: (@character, @color) ->
  show: ->
    charm.position( @x, @y ).foreground( @color ).write @character

e = (ch, co, x, y) ->
  en = new Entity ch, co
  en.x = x
  en.y = y
  en

entities = [
  e '¥', 'red', 7, 5
  e '¥', 'red', 1, 15
  e '¥', 'red', 27, 25
  e '¥', 'red', 14, 17
  e '¤', 'cyan', 15, 15
]

setInterval( (->
  charm.position( 0, rows-1 )
  charm.erase 'up'
  entity.show() for entity in entities
  charm.position( cols-1, rows-1 )
), 100)

exiting = no

charm.on '^]A', ->
  message 'foobar', 'red'

charm.removeAllListeners('^C')
charm.on '^C', ->
  unless exiting
    exiting = yes
    message('^C again to quit...','cyan')
    return
  charm.reset()
  process.exit()
