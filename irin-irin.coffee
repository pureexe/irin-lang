irin = require "./src/irin-lang.coffee"
readline = require "readline"
fs = require "fs"
rl = readline.createInterface
  input: process.stdin
  output: process.stdout
console.log "=========================="
console.log "Name : prototype"
console.log "Language : IRIN"
console.log "=========================="
bot = undefined
runBot = ()->
    rl.question ">> ", (inp)->
      console.log "ไอริน : "+bot.reply(inp)
      runBot()
fs.readFile 'brain/irin.irin', 'utf8', (err,data) ->
  bot = new irin(data)
  runBot()
