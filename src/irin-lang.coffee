"""
Todolist:
  - function
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
    unuseArray = []
    for ch in @expression
      if ch is "("
        unuseArray.push("(");
      else if ch is "["
        unuseArray.push("[");
    @expression = @expression.replace(new RegExp("\\s*\\[","g"), "(")
    @expression = @expression.replace(new RegExp("\\]\\s*","g"), ")?")
    @expression = @expression.replace(new RegExp("\\s*\\(","g"), "(")
    @expression = @expression.replace(new RegExp("\\)\\s*","g"), ")")
    @expression = @expression.replace(new RegExp("\\s*\\*\\s*","g"),"(.+)")
    processed = ""
    isOpenBucket = false
    stackOpenBucket = 0
    # Remove Neet bracket cause it will make return error
    for ch in @expression
      if ch is "("
        if isOpenBucket
          stackOpenBucket++
          continue
        else
          isOpenBucket = true
      else if ch is ")"
        if stackOpenBucket > 0
          stackOpenBucket--
          continue
        else
          isOpenBucket = false;
      processed+=ch
    processed = new RegExp(processed)
    if not processed.test(@text)
      return undefined
    parsedArray = @text.match(processed)
    parsedArray.splice(0,1)
    while (index = unuseArray.indexOf("[")) > -1
      parsedArray.splice(index,1)
      unuseArray.splice(index,1)
    resultArray = []
    for element in parsedArray
      resultArray.push(element.trim())
    return resultArray

  mergeExpression: (@expression,@rData)->
    #Todo : merge array to answer before output
    buffer = ""
    openBracket = false
    for ch in @expression
      if ch is "{"
        openBracket = true
      else if ch is "}"
        console.log @expression.slice(0, @expression.indexOf("{"))
        @expression = @expression.slice(0, @expression.indexOf("{"))+@rData[parseInt(buffer)-1]+@expression.slice(@expression.indexOf("}")+1)
        openBracket = false
        buffer = ""
      else if openBracket
        buffer+=ch
    return @expression

  selectChild: (@text, @head)->
    for child in @head.next
      #this condition need to change to regular expression "later"
      if answerData = @testExpression(@text,child.text)
        select = Math.floor(Math.random()*child.next.length)
        return {node:child.next[select],data:answerData}
    return undefined

  reply: (@text)->
    answer = @selectChild(@text,@data.head)
    if answer
      @data.head = answer.node
      return @mergeExpression(answer.node.text,answer.data)
    @data.head = @data.graph
    answerNode = @selectChild(@text,@data.head)
    if answer
      @data.head = answer.node
      return @mergeExpression(answer.node.text,answer.data)
    return "[Log:Error] answer not found"

module.exports = irin
