# irin-lang
Indent to Recognize for Intelligent Natural language or IRIN is the programming language which use indent to descibe question and answer for chatterbot. It's design for shorter script and easier for newbie. compatible test with English and Thai.

This repo `irin-lang` is interpreter for irin language. it's written on coffeescript and make to compatible with javascript in browser side and server side.

If you have any question or any problem. Let's me hear at [Github issue](https://github.com/pureexe/irin-lang/issues)

## How to scripting irin

irin language has divided into two part that call Head and Body. In head use to define variable and body use to define question and answer for chatterbot. You can scripting without head. irin script must save in `.irin` file extension. In body use indent to descibe question or answer. You can indent by use Tab or space. Here is example.

```
Hello
  Hi!
```
when you type `hello`. Don't worry about case sensitive on question. bot will reply `Hi!`. Line without indent always question. And greater deep level is answer. And next greater level is question.

And irin language has many feature. such as in-line condition. define topic in seperate files information. So please read [documentation](https://github.com/pureexe/irin-lang/wiki) to find them out.

## Installation

irin-lang interpreter is available via NPM you can download by
```
npm install --save irin-lang
```

and available on Bower too. you can download by
```
bower install --save irin-lang
```

Don't worry if you isn't use both NPM and Bower. you can directly download from [Github Repo Release](https://github.com/pureexe/irin-lang/releases)

by using Node.js or CommonJS
``` javascript
var Irin = require("irin-lang")
```

by using normal browser
``` html
<script src="path/to/irin-lang.min.js"></script>
```

then you must check for make sure everything work correctly. by create file `hello.irin`
```
hello
  Hello world!
```  
and write this javascript to run `hello.irin` with input `hello`
```  javascript
var bot = new Irin("hello.irin",function(err){
  if(err){
    throw err;
  }
  console.log(bot.reply("hello"));
});
```  
if everything work fine. you should see `Hello world!` from console.
if you ran into problem. try to fix it by your safe. if nothing work. Let's me here at [Github issue](https://github.com/pureexe/irin-lang/issues)

and finally you is ready to learn irin language. Please read [documentation](https://github.com/pureexe/irin-lang/wiki) to continue.

## Documentation
documentation is available in Thai and English.
- ภาษาไทย [ภาษา.ไอริน.ไทย](https://ภาษา.ไอริน.ไทย)
- English [lang.irin.in.th](https://lang.irin.in.th) and [Repo Wiki](https://github.com/pureexe/irin-lang/wiki)

## LICENSE

this project has been supported
by the National Electronics and Computer Technology Center (NECTEC)

Please read custom license from LICENSE in this repository.

## Develop by
Pakkapon Phongthawee  
Email : phongthawee_p@silpakorn.edu  
Personal Website: [www.pureapp.in.th](https://www.pureapp.in.th)  
