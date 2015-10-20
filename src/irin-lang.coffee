##
# IRIN project
# @class
# @todo Syntax check before parse
# @todo file header read
# @todo much and more
# @public
#

class irin
  data:
    graph: []
    head: []
    global: {}
  config:
    indent:
      len: 2
  env:
    runtime = ""

  ##
  # just a simple class constructor
  # @todo remove steam just only input and import from parse method only
  # @param {string} steam is input script
  # @param {string} option is configulation
  #
  constructor: (@steam, @option) ->
    #if have custom config then load custom config
    if @option and @option.indent
      if @option.indent.len
        @config.indent.len = @option.indent.len
    #parse irin language to graph
    @data.graph = @parse(@steam)
    @data.graph = {next:@data.graph}
    @data.head = @data.graph
  ##
  # export all data graph for debuging
  # @todo remove on release code
  getGraph:()->
    return @data.graph
  ##
  # Convert from irin script to data graph
  # @todo make parse to async
  # @todo add header read feature
  # @todo syntax check before parse
  # @param {string} expression - the expression
  #
  parse: (@steam)->
    resultGraph = []
    currentGraph = resultGraph
    currentIndent = 0
    splitSteam = @steam.split "\n"
    multiLineComment = false
    functionObject = {}
    functionHead = []
    isAddtoFunction = false
    currentAddtoFunction = ""
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

      #function parse
      if text.substring(0,2) == "->"
        text = text.substring(2,text.length)
        text = text.trim()
        if textIndent == 0
        #declarefunction
          if not functionObject[text]
            functionObject[text] = []
          currentAddtoFunction = text
          isAddtoFunction = true
          functionHead = functionObject[text]
          continue
        #activefunction
        else
          if currentIndent == textIndent
            cloneObj.depth = currentIndent
            currentGraph.push(functionObject[text].next)
          else if textIndent>currentIndent
            if not functionObject[text]
              functionObject[text] = []
            currentGraph[currentGraph.length-1].next = functionObject[text]
            continue
      #add to graph
      #add to functionObject
      if isAddtoFunction
        if textIndent is currentIndent
          functionHead.push {text:text,depth:textIndent,next:[]}
          if functionHead.length > 1
            functionHead[functionHead.length - 2].next = functionHead[functionHead.length - 1].next
        else if textIndent > currentIndent
          currentIndent = textIndent
          functionHead = functionHead[functionHead.length-1].next
          functionHead.push {text:text,depth:textIndent,next:[]}
        else
          # if textIndent is zero so it end of function declare
          if textIndent == 0
            currentAddtoFunction = ""
            isAddtoFunction = false
            currentGraph = resultGraph
            currentIndent = 0
            while textIndent != currentIndent
              currentIndent++
              currentGraph = currentGraph[currentGraph.length-1].next
            currentGraph.push {text:text,depth:textIndent,next:[]}
          else
            functionHead = resultGraph
            currentIndent = 0
            while textIndent != currentIndent
              currentIndent++
              functionHead = functionHead[functionHead.length-1].next
            functionHead.push {text:text,depth:textIndent,next:[]}
      #add to resultGraph
      else
        if textIndent is currentIndent
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

  ##
  # Convert from irin expression to regular expression
  # @todo merge global data before change Irin Expression to Regular Expression
  # @param {string} expression - the expression
  #
  toRegular:(expression)->
    regularExp = ""
    expression = expression.replace(/\*/g, "(.+)")
    i = 0
    while i < expression.length
      if expression[i] == "["
        j = 0
        while expression[i+j] != "]"
          j++
        optionals = expression.substring(i+1,i+j).split("|")
        if i+j<expression.length and expression[i+j+1]==" "
          k = 0
          while k < optionals.length
            optionals[k] = optionals[k]+"(?:\\s|\\b)+"
            k++
          j++
        if i > 0 and expression[i-1]==" "
          regularExp = regularExp.trim()
          k = 0
          while k < optionals.length
            optionals[k] = "(?:\\s|\\b)+"+optionals[k]
            k++
          optionals.push("(?:\\b|\\s)+")
        else
          optionals.unshift("")
        optionals = optionals.join("|")
        optionals = optionals.replace(new RegExp(@escape("(.+)"), "g"),"(?:.+)")
        regularExp+="(?:"+optionals+")"
        i+=j+1
      else
        regularExp+=expression[i]
        i++
    return "^"+regularExp+"$"

  ##
  # escape regular expression unsafe string
  # @param {string} expression - the expression
  #
  escape: (expression) ->
    unsafe = "\\.+*?[^]$(){}=!<>|:".split("")
    for char in unsafe
      expression = expression.replace(new RegExp("\\#{char}", "g"), "\\#{char}")
    return expression

  ##
  # Try to Match expression
  # @param {string} expression - the expression
  # @param {string} input - input to test expression
  #
  match:(input,expression)->
    cExp = new RegExp(@toRegular(expression))
    result = input.match(cExp)
    if result
      result.shift()
      return result
    else
      return undefined

  ##
  # Merge reply expression with reply data
  # @todo change it to better version Merge
  # @param {string} expression - the expression
  # @param {string} rData - the list of reply array
  #
  mergeExpression: (@expression,@rData)->
    #Todo : merge array to answer before output
    buffer = ""
    openBracket = false
    for ch in @expression
      if ch is "{"
        openBracket = true
      else if ch is "}"
        @expression = @expression.slice(0, @expression.indexOf("{"))+@rData[parseInt(buffer)-1]+@expression.slice(@expression.indexOf("}")+1)
        openBracket = false
        buffer = ""
      else if openBracket
        buffer+=ch
    return @expression

  ##
  # Loop in current head child if found match expression then random answer from child's child node
  # @private
  # @param {string} expression - the expression
  # @param {string} rData - the list of reply array
  #
  selectChild: (@text, @head)->
    for child in @head.next
      #this condition need to change to regular expression "later"
      if answerData = @match(@text,child.text)
        select = Math.floor(Math.random()*child.next.length)
        return {node:child.next[select],data:answerData}
    return undefined

  ##
  # findReply from data graph
  # @todo make reply to async
  # @param {string} input text
  #
  reply: (@text)->
    answer = @selectChild(@text,@data.head)
    if answer
      @data.head = answer.node
      return @mergeExpression(answer.node.text,answer.data)
    @data.head = @data.graph
    answer = @selectChild(@text,@data.head)
    if answer
      @data.head = answer.node
      return @mergeExpression(answer.node.text,answer.data)
    return "[Log:Error] answer not found"

module.exports = irin
