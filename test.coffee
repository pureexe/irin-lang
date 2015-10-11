irin = require "./src/irin-lang"
fs = require "fs"

fs.readFile 'brain/prototype.irin', 'utf8', (err,data) ->
  bot = new irin(data)
  console.log bot.reply("กินข้างหรือยัง")
  console.log bot.reply("ข้าวอร่อยไหม")
