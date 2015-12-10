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
runBot = ()->
  rl.question ">> ", (inp)->
    console.log bot.reply(inp)
    runBot()
bot = new irin 'brain/en-main.irin', (err)->
  if err
    console.log "ERROR FOUND : #{err.error} | line: #{err.line}"
  runBot()
