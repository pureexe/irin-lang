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
    @data.graph = @parse @steam
    @data.graph = {next:@data.graph}
    @data.head = @data.graph

  parse: (@steam)->
    resultGraph = []
    currentGraph = resultGraph
    currentIndent = 0
    splitSteam = @steam.split "\n"
    for text in splitSteam
      textIndent = text.search /\S/
      if textIndent == -1
        continue
      text = text.substring textIndent, text.length
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

  reply: (@text)->
    foundAnswer = false
    answer = ""
    for child in @data.head.next
      #this condition need to change to regular expression "later"
      if @text == child.text or child.text== "*"
        select = Math.floor(Math.random()*child.next.length)
        answer = child.next[select].text
        @data.head = child.next[select]
        foundAnswer = true
        break
    #if not found answer in child node then search in root node
    if not foundAnswer
      @data.head = @data.graph
      for child in @data.head.next
        #this condition need to change to regular expression "later"
        if @text == child.text or child.text == "*"
          select = Math.floor(Math.random()*child.next.length)
          answer = child.next[select].text
          @data.head = child.next[select]
          foundAnswer = true
          break
    if not foundAnswer
      return "Matching failed"
    else
      return answer
  #This is expression test
  test: (@input, @expression)->
    #"hello pure kung".match(/hello (.+) kung/)


module.exports = irin
