##
# IRIN project
# @class
# @todo Syntax check before parse
# @todo make mergeExpression support dynamic set values and inline condition
# @todo file header read
# @todo much and more
# @public
#
class Irin
  data:
    graph: []
    head: []
    global: {}
  config:
    indent:
      len: 2
    includeDepth: 50
  env:
    runtime: 'node'
    node:
      fs: ''

  ##
  # just a simple class constructor
  # @todo implement browser input
  # @param {string} steam is input script
  # @param {string} option is configulation
  #
  constructor: (@file, @option,@callback) ->
    if typeof @file is 'string'
      file = @file
      if typeof @option is 'object'
        option = @option
        callback = @callback
      else
        callback = @option
    else if typeof @file is 'object'
      option = @file
      callback = @option
    else if typeof @file is 'function'
      callback = @file
    @env.runtime = @runtime()
    self = @
    @parse file,(err,cb)->
      if cb
        self.data.graph = {next:cb.graph}
        self.data.head =  self.data.graph
        self.data.global = cb.variable
    callback()

  ##
  # Convert from irin script to data graph
  # @todo make parse to async
  # @todo add header read feature
  # @todo syntax check before parse
  # @param {string} file - filelocation
  # @param {function} callback - filelocation
  parse:(file,callback) ->
    @parseWorker(file,0,callback)

  ##
  # worker for parse function to async problem
  #
  parseWorker:(file,stack,callback)->
    if stack > @config.includeDepth
      console.error("stack crash")
      callback({error:"FOREVER_LOOP"})
    else
      self = @
      @readFile file, (err,steam)->
        if err
          callback err
        else
          self.parseProcess steam.toString(),stack,callback
  ##
  # main function for parse
  #
  parseProcess:(steam,stack,callback)->
    steam = @removeComment steam
    lines = steam.split("\n")
    state =
      currentLine: 0
      currentIndent: 0
      pastIndent: 0
      readingHeader: false
      readingInclude: false
      functionObject:{}
      functionHead:{}
      currentFuncName:""
      graph:[]
      variable:{}
      includeVariable:[]
      headerDepth: 0
      isAddtoFunction: false
    state.currentGraph = state.graph
    indentLen = @config.indent.len
    self = @
    savedState = []
    callbackListener = (err,data)->
      if err
        callback err
      if data
        state = savedState.pop()
        state.currentIndent = 0
        state.currentGraph = state.graph
        while state.currentIndent != state.headerDepth
          state.currentIndent++
          state.currentGraph = state.currentGraph[state.currentGraph.length-1].next
        state.currentGraph.push.apply(state.currentGraph,data.graph)
        state.pastIndent = state.headerDepth
      while state.currentLine < lines.length
        text = lines[state.currentLine]
        state.currentIndent = self.countIndent(text)
        if text.trim().indexOf("---") > -1
          if state.readingHeader
            state.readingHeader = false
          else
            state.headerDepth = state.currentIndent
            state.readingHeader = true
          state.currentLine++
          continue
        if state.readingHeader and text.trim().substring(0,2) is "->"
          state.readingInclude = true
          state.currentLine++
          savedState.push(state)
          fileAddr = text.trim().substring(2,text.length).trim()
          self.parseWorker(fileAddr,stack+1,callbackListener)
          return undefined
        if state.readingHeader and text.indexOf("<-")
          word = text.split("<-")
          if word.length > 2
            ## Error more than <- in same paragraph ##
          else
            state.variable[word[0].trim()] = word[1].trim()
        text = text.trim()
        ## Function parse
        if text.substring(0,2) == "->" and not state.readingHeader
          text = text.substring(2,text.length)
          text = text.trim()
          if state.currentIndent == 0
          #declarefunction
            if not state.functionObject[text]
              state.functionObject[text] = []
            state.currentFuncName = text
            state.isAddtoFunction = true
            state.functionHead = state.functionObject[text]
            state.currentLine++
            continue
          else
            if not state.functionObject[text]
              state.functionObject[text] = []
            if state.pastIndent == state.currentIndent
              state.currentGraph.push(state.functionObject[text])
            else if state.currentIndent>state.pastIndent
              state.currentGraph[state.currentGraph.length-1].next = state.functionObject[text]
            state.currentLine++
            continue
        if state.isAddtoFunction and state.currentIndent == 0
          state.isAddtoFunction = false
        if state.isAddtoFunction
          if state.currentIndent is state.pastIndent
            state.functionHead.push {text:text,depth:state.currentIndent,next:[]}
            if state.functionHead.length > 1 and state.functionHead[state.functionHead.length - 2].next.length == 0
              state.functionHead[state.functionHead.length - 2].next =
                state.functionHead[state.functionHead.length - 1].next
          else if state.currentIndent > state.pastIndent
            ## define when tab is greater
            state.pastIndent = state.currentIndent
            while state.functionHead[state.functionHead.length-1].next.length
              state.functionHead = state.functionHead[state.functionHead.length-1].next
              state.currentIndent++
            state.functionHead = state.functionHead[state.functionHead.length-1].next
            state.functionHead.push {text:text,depth:state.currentIndent,next:[]}
          else if state.currentIndent < state.pastIndent
            ## define when tab is lesster
            state.functionHead = state.functionObject[state.currentFuncName]
            state.pastIndent = state.currentIndent
            while state.currentIndent != state.pastIndent
              state.currentIndent++
              state.functionHead = state.functionHead[state.currentGraph.length-1].next
            state.functionHead.push {text:text,depth:state.currentIndent,next:[]}
          state.currentLine++
          continue
        ## Begin normal parse algorithm
        if state.currentIndent is state.pastIndent
          ## define when tab is equal
          state.currentGraph.push {text:text,depth:state.currentIndent,next:[]}
          if state.currentGraph.length > 1 and state.currentGraph[state.currentGraph.length - 2].next.length == 0
            state.currentGraph[state.currentGraph.length - 2].next =
              state.currentGraph[state.currentGraph.length - 1].next
        else if state.currentIndent > state.pastIndent
          ## define when tab is greater
          state.pastIndent = state.currentIndent
          while state.currentGraph[state.currentGraph.length-1].next.length
            state.currentGraph = state.currentGraph[state.currentGraph.length-1].next
            state.currentIndent++
          state.currentGraph = state.currentGraph[state.currentGraph.length-1].next
          state.currentGraph.push {text:text,depth:state.currentIndent,next:[]}
        else if state.currentIndent < state.pastIndent
          ## define when tab is lesster
          state.currentGraph = state.graph
          state.pastIndent = state.currentIndent
          while state.currentIndent != state.pastIndent
            state.currentIndent++
            state.currentGraph = state.currentGraph[state.currentGraph.length-1].next
          state.currentGraph.push {text:text,depth:state.currentIndent,next:[]}
        state.currentLine++
      callback(undefined,{graph:state.graph,variable:state.variable});

      # you should parse in this callback and terminate if found include
      # and then cotinue from state when got callback later
    callbackListener()
  ##
  # count text indent
  #
  countIndent:(text)->
    indent = (text.search /\S/)
    if indent is -1
      indent = 0
    else
      indent = indent/@config.indent.len
    return indent
  ##
  # remove comment from sourcecode
  #
  removeComment: (steam)->
    splitSteam = steam.split "\n"
    output = []
    multiComment = false
    for line in  splitSteam
      if line.indexOf("###") > -1
        if multiComment
          multiComment = false
          line = line.substring(line.indexOf("###")+3,line.length)
        else
          multiComment = true
          line = line.substring(0,line.indexOf("###"))
      else if line.indexOf("#") > -1
        line = line.substring(0,line.indexOf("#"))
      if line.trim().length is 0
        continue
      if multiComment
        continue
      output.push line
    return output.join "\n"

  ##
  # Convert from irin expression to regular expression
  # @todo merge global data before change Irin Expression to Regular Expression
  # @param {string} expression - the expression
  #
  toRegular:(expression)->
    expression = @mergeExpression(expression)
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
  # @todo need to make Captialize and non Captialize match
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
  mergeExpression: (expression,rData)->
    #Todo : merge array to answer before output
    #Todo : make this function support dynamic set values and inline condition
    buffer = ""
    stackBracket = 0
    front = 0
    rear = 0
    i = 0
    while i < expression.length
      ch = expression[i]
      if ch is "{"
        if stackBracket is 0
          buffer = ""
          front = i
        else
          buffer+="{"
        stackBracket++
      else if ch is "}"
        stackBracket--
        if stackBracket is 0
          rear = i
          buffer = buffer.trim()
          if buffer.indexOf("}") != -1
            buffer = @mergeExpression(buffer,rData)
          if buffer.indexOf("?") != -1 || buffer.indexOf("<-") != -1
            if buffer.indexOf("?") !=-1
              buffer = @inlineCondition(buffer)
            if buffer.indexOf("<-") !=-1
              newData = buffer.split("<-")
              buffer = ""
              if newData.length >2
                buffer = undefined ##Got error so Need to defined error later
              else
                @data.global[newData[0].trim()] = newData[1].trim()
          else
            if not isNaN(parseInt(buffer))
              buffer =rData[parseInt(buffer)]
            else
              buffer = @data.global[buffer]
          frontside = expression.slice(0,front)+buffer
          i = frontside.length-1
          expression = frontside+expression.slice(rear+1)
        else
          buffer+="}"
      else
        buffer+=ch
      i++
    return expression
  ##
  # convert inlineCondtion to conditonTree
  # Warning: this tree is circular loop don't print it out
  # @param {string} coditionStatment
  #
  inlineToConditionTree: (input)->
    tree = {data:undefined,prev:undefined}
    head = tree
    buffer = ""
    justleft = false
    for ch in input
      if ch == "?"
        head.data = buffer
        buffer = ""
        head.left = {data:undefined,prev:head}
        head = head.left
      else if ch == ":"
        head.data=buffer
        buffer =""
        head = head.prev
        while head.right
          head = head.prev
        head.right = {data:undefined,prev:head}
        head = head.right
      else
        buffer +=ch
    head.data = buffer
    return tree
  ##
  # check is charater is a operator
  # @param {string} charater operator
  #
  checkOperator: (input)->
    oprs = ["(",")","!","&&","||","==","!=",">=","<=",">","<","*","/","+","-"]
    for opr in oprs
      if input is opr
        return true
    return false

  tokenizeOperator: (input)->
    input = [input]
    buffer = []
    buffer2 = []
    oprs = ["(",")","!","&&","||","==","!=",">=","<=",">","<","*","/","+","-"]
    for opr in oprs
      for word in input
        if word.indexOf(opr)>-1
          buffer2 = word.split(opr)
          for b in buffer2
            if b != ''
              buffer.push(b)
            buffer.push(opr)
          buffer.pop()
        else
          buffer.push(word)
      input = buffer
      buffer = []
    return input

  ##
  # convert condtionStament to Reverse Polish notation
  # @see https://en.wikipedia.org/wiki/Reverse_Polish_notation
  # @param {string} coditionStatment
  #
  convertToRPN: (input)->
    infix = @tokenizeOperator(input)
    output = []
    oprStack = []
    for ch in infix
      if @checkOperator ch
        if ch is ')'
          while oprStack.length>0 and oprStack[oprStack.length-1] != '('
            output.push(oprStack.pop())
          oprStack.pop()
        else
          oprStack.push(ch)
      else
        output.push(ch)
    while oprStack.length>0
      output.push(oprStack.pop())
    return output

  ##
  # processing condition statment is true or false
  # @param {string} coditionStatment
  #
  testCondition: (input)->
    rpn = @convertToRPN(input)
    bufStack = []
    for word in rpn
      if word is "!"
        bufStack.push(!bufStack.pop())
      else if word is "&&"
        bufStack.push(bufStack.pop()&&bufStack.pop())
      else if word is "||"
        bufStack.push(bufStack.pop()||bufStack.pop())
      else if word is "=="
        bufStack.push(bufStack.pop()==bufStack.pop())
      else if word is "!="
        bufStack.push(!(bufStack.pop()!=bufStack.pop()))
      else if word is ">="
        bufStack.push(!(bufStack.pop()>=bufStack.pop()))
      else if word is "<="
        bufStack.push(!(bufStack.pop()<=bufStack.pop()))
      else if word is ">"
        bufStack.push(!((bufStack.pop()>bufStack.pop())))
      else if word is "<"
        bufStack.push(!bufStack.pop()<bufStack.pop())
      else if word is "*"
        bufStack.push(parseFloat(bufStack.pop())*parseFloat(bufStack.pop()))
      else if word is "/"
        bufStack.push(parseFloat(bufStack.pop())/parseFloat(bufStack.pop()))
      else if word is "-"
        bufStack.push(parseFloat(bufStack.pop())-parseFloat(bufStack.pop()))
      else if word is "+"
        a = bufStack.pop()
        b = bufStack.pop()
        if not isNaN(parseFloat(a)) and not isNaN(parseFloat(b))
          bufStack.push(parseFloat(a)+parseFloat(b))
        else
          bufStack.push(a+b)
      else
        bufStack.push(word)
    return bufStack[0]

  ##
  # condition statment tree traversal
  # @param {string} conditionTree
  #
  conditionWorker: (node)->
    if node.left and node.right
      if @testCondition(node.data)
        return @conditionWorker(node.left)
      else
        return @conditionWorker(node.right)
    else
      return node.data

  ##
  # processing inline codition statment
  # @param {string} inline codition statement
  #
  inlineCondition: (input)->
    tree = @inlineToConditionTree(input)
    return @conditionWorker(tree)

  ##
  # Loop in current head child if found match expression
  # then random answer from child's child node
  # @private
  # @param {string} expression - the expression
  # @param {string} rData - the list of reply array
  #
  selectChild: (@text, @head)->
    for child in @head.next
      #this condition need to change to regular expression "later"
      if answerData = @match(@text.toUpperCase(),child.text.toUpperCase())
        select = Math.floor(Math.random()*child.next.length)
        return {node:child.next[select],data:answerData}
    return undefined

  ##
  # findReply from data graph
  # @todo make reply to async
  # @param {string} input text
  #
  reply: (@text,callback)->
    answer = @selectChild(@text,@data.head)
    if answer
      @data.head = answer.node
      return @mergeExpression(answer.node.text,answer.data)
    else
      @data.head = @data.graph
      answer = @selectChild(@text,@data.head)
      if answer
        @data.head = answer.node
        return @mergeExpression(answer.node.text,answer.data)
      else
        return "[Log:Error] answer not found"
 ##
 # use to readfile with node and browser
 # @param file path location
 # @param callback(error,susccess)
 # @todo impletement XML request
 #
  readFile:(file,callback)->
    if @env.runtime is 'node'
      @env.node.fs.readFile file, 'utf8', (err,fileData) ->
        callback(err,fileData)
    #else if @env.runtime is 'browser'
    #  need to impletement XML request later


 ##
 # check environment is node or browser
 #
  runtime: ()->
    # In Node, there is no window, and module is a thing.
    if typeof(window) is "undefined" and typeof(module) is "object"
      @env.node.fs = require "fs"
      return "node"
    return "browser"
module.exports = Irin
