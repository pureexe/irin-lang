"""
Todolist:
  - testExpression
  - mergeExpression
  - fileheader
  - much & more
"""
class irin
  data:
    graph: []
    head: []

  config:
    indent:
      len: 2

  constructor: (@steam, @option) ->
    #if have custom config then load custom config
    if @option and @option.indent
      if @option.indent.len
        @config.indent.len = @option.indent.len
    #parse irin language to graph
    @data.graph = @parse(@steam)
    @data.graph = {next:@data.graph}
    @data.head = @data.graph

  parse: (@steam)->
    resultGraph = []
    currentGraph = resultGraph
    currentIndent = 0
    splitSteam = @steam.split "\n"
    multiLineComment = false
    for text in splitSteam
      #remove Single line comment
      if text.indexOf("#") > -1
        text = text.substring(0,text.indexOf("#"));
      #remove Multi line Comment
      if multiLineComment
        if text.indexOf("\"\"\"") == -1
          continue
        else
          text = text.slice(text.indexOf("\"\"\"")+3)
          multiLineComment = false
      if text.indexOf("\"\"\"")> -1
        if not multiLineComment
          commentStartPos = text.indexOf("\"\"\"")
          text = text.slice(0, commentStartPos) + text.slice(commentStartPos+3);
          if text.indexOf("\"\"\"")> -1
            text = text.slice(0, commentStartPos) + text.slice(text.indexOf("\"\"\"")+3);
          else
            text = text.substring(0,commentStartPos)
            multiLineComment = true
      #count textIndent
      textIndent = text.search /\S/
      if textIndent == -1
        continue
      text = text.trim()
      textIndent = textIndent/@config.indent.len
      if textIndent == currentIndent
        currentGraph.push {text:text,depth:textIndent,next:[]}
        #pointer link to same child for multiqustion on same answer
        if currentGraph.length > 1
          currentGraph[currentGraph.length - 2].next = currentGraph[currentGraph.length - 1].next
      #travle deeper
      else if textIndent > currentIndent
        currentIndent = textIndent
        currentGraph = currentGraph[currentGraph.length-1].next
        currentGraph.push {text:text,depth:textIndent,next:[]}
      #end of route so restart new at root
      else
        currentGraph = resultGraph
        currentIndent = 0
        while textIndent != currentIndent
          currentIndent++
          currentGraph = currentGraph[currentGraph.length-1].next
        currentGraph.push {text:text,depth:textIndent,next:[]}
    return resultGraph

  testExpression: (@text,@expression)->
    #Todo : expression text for selectChild

  mergeExpression: (@expression,@info)->
    #Todo : merge array to answer before output

  selectChild: (@text, @head)->
    for child in @data.head.next
      #this condition need to change to regular expression "later"
      if @text == child.text or child.text== "*"
        select = Math.floor(Math.random()*child.next.length)
        return child.next[select]
    return undefined

  reply: (@text)->
    answerNode = @selectChild(@text,@data.head)
    if answerNode
      @data.head = answerNode
      return answerNode.text
    @data.head = @data.graph
    answerNode = @selectChild(@text,@data.head)
    if answerNode
      @data.head = answerNode
      return answerNode.text
    return "[Log:Error] answer not found"

module.exports = irin
  #This is expression test
  #"hello pure kung".match(/hello (.+) kung/) // hello * kung
  #"hello mu kung".match(/hello (box|des|mu)? kung/) // hello [box|des|mu] kung
  #"butt no home".match(new RegExp("(.+)?no(.+)")) // [*] no *
  #need to replace \s* on blankspance?
