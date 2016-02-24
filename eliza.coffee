irin = require "./src/irin-lang.coffee"
readline = require "readline"
colors = require "colors"
fs = require "fs"
rl = readline.createInterface
  input: process.stdin
  output: process.stdout
console.log "=========================="
console.log "Name : ELIZA"
console.log "=========================="
runBot = ()->
  rl.question ">> ".yellow, (inp)->
    console.log bot.reply(inp).cyan
    runBot()
bot = new irin 'brain/eliza.irin', (err)->
  if err
    console.log "ERROR FOUND : #{err.message} | file: #{err.file} | line: #{err.line}"
  else
    runBot()
