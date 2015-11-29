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
bot = new irin 'brain/prototype.irin', ()->
  runBot()
runBot = ()->
  rl.question ">> ", (inp)->
    console.log bot.reply(inp)
    runBot()
