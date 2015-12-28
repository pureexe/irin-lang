#CHANGELOG

## v0.0.4
- fix: `->` on difference directory
- fix: expression `-` and `/` is wrong because stack popping error.
- fix: regular expression escape
- fix: declare variable which isn't following top-down law
- fix: `###` multiline comment working incorrectly  `###`
- add: support data<-{other_variable}+5 in header
- add: error Unexpected declaration in header.
- add: error Variable name must not start with number.
- add: error unexpected indentation
- remove: error Header must have no indent. (replace by unexpected indentation)

## v0.0.3
- fix: wrong next pointer in method parseProcess
- fix: inline-condition return true on undefined and NaN
- fix: undefined on answer {}, it should be empty
- add: {0} is user input

## v0.0.2
- fix: topic wrong pointer next node
- fix: in-line variable work incorrectly because conflict on `==` and `===`
- fix: error has been detect wrong line
- fix: crash on answer node is missing
- fix: crash on reply parameter is empty string
- fix: crash on countIndent()
- fix: crash on chrome
- add: error if reply input isn't string
- add: error if input file path isn't string
- add: error when call reply before Irin class callback
- add: error when multiline comment without closing tag

## v0.0.1
- initial Release
- tested with browser and node.js
- tested with Thai and English language
- more, see documentation
