isNumber = (char) -> char in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

isLowercaseLetter = (char) -> char in ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

isUppercaseLetter = (char) -> char in ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

isLetter = (char) -> isLowercaseLetter(char) or isUppercaseLetter(char)

isUnderscore = (char) -> char is "_"

isAlphanumeric = (char) -> isNumber(char) or isLetter(char) or isUnderscore(char)

isNewline = (char) -> char in ["\n", "\r", "\n\r", "\r\n"]

isKeyword = (identifier) -> identifier in ["if", "function", "and", "then", "do", "for", "while", "end", "repeat", "until", "local", "goto", "or", "not", "true", "false", "return", "else", "elseif", "nil", "in", "switch", "when", "case", "is", "isnt", "unless", "elif", "def", "new", "class"]

isOperator = (identifier) -> identifier in ["=", "+", "-", ":", ";", ",", "*", "/", ">", "<", "<=", ">=", "~=", "~", "^", "..", "==", "%", "#", "?", "..", "...", "."]

isWhitespace = (char) -> char in [" ", "\t"]

isBracket = (char) -> char in ["(", ")"]

isSquareBracket = (char) -> char in ["[", "]"]

isCurlyBrace = (char) -> char in ["{", "}"]



TokenType =
	NUMBER: "NUMBER"
	IDENTIFIER: "IDENTIFIER"
	COMMENT: "COMMENT"
	MULTILINE_COMMENT: "MULTILINE_COMMENT"
	STRING: "STRING"
	KEYWORD: "KEYWORD"
	OPERATOR: "OPERATOR"
	OTHER: "OTHER"
	WHITESPACE: "WHITESPACE"
	BRACKET: "BRACKET"
	SQUARE_BRACKET: "SQUARE_BRACKET"
	CURLY_BRACE: "CURLY_BRACE"
	NEWLINE: "NEWLINE"
	EOF: "EOF"



class Tokenizer
	constructor: (@source) ->
		@length = @source.length
		@characterIndex = -1
		@lineNumber = 1
		@currentToken = ""
		@currentCharacter = ""
		@parseMultiline = null
		@next = ""



	nextChar: ->
		@characterIndex += 1
		if @characterIndex >= @length
			return null

		character = @source.charAt @characterIndex
		if isNewline character
			@lineNumber += 1

		return character



	peek: (amount = 1) ->
		if @characterIndex + amount >= @length
			return null
		else
			return @source.charAt @characterIndex + amount



	parseNumber: ->
		@currentToken = @currentCharacter

		while @next? and (isNumber(@next) or @next is ".")
			@currentToken += @nextChar()
			@next = @peek()

		return [@currentToken, TokenType.NUMBER]



	parseIdentifier: ->
		@currentToken = @currentCharacter

		while @next? and isAlphanumeric @next
			@currentToken += @nextChar()
			@next = @peek()

		if isKeyword @currentToken
			return [@currentToken, TokenType.KEYWORD]
		else
			return [@currentToken, TokenType.IDENTIFIER]



	parseMultilineComment: ->
		@parseMultiline = @parseMultilineComment

		if isNewline @currentCharacter
			char = @currentCharacter
			@currentCharacter = ""
			return [char, TokenType.MULTILINE_COMMENT]

		while true
			@currentCharacter = @nextChar()

			break unless @currentCharacter?

			if isNewline @currentCharacter
				break

			@currentToken += @currentCharacter

			if @currentCharacter is "]" and @peek() is "]"
				@currentToken += @nextChar()
				@parseMultiline = null
				break

		return [@currentToken, TokenType.MULTILINE_COMMENT]



	parseComment: ->
		@currentToken = @currentCharacter
		@currentToken += @nextChar()
		@next = @peek()

		if @next is "[" and @peek(2) is "["
			return @parseMultilineComment()

		else
			while @next? and not isNewline @next
				@currentToken += @nextChar()
				@next = @peek()
			return [@currentToken, TokenType.COMMENT]



	parseString: ->
		@currentToken = @currentCharacter
		stringOpener = @currentCharacter

		readEscapeCharacter = no

		while @next?
			@next = @peek()
			if @next is stringOpener and not readEscapeCharacter
				break

			if not readEscapeCharacter and @next is "\\"
				readEscapeCharacter = yes
			else
				readEscapeCharacter = no

			@currentToken += @nextChar()
			
				


		@currentToken += @nextChar()

		return [@currentToken, TokenType.STRING]



	parseOther: ->
		@currentToken = @currentCharacter

		if isWhitespace @currentCharacter
			@next = @peek()
			while @next? and isWhitespace @next
				@currentToken += @nextChar()
				@next = @peek()

			return [@currentToken, TokenType.WHITESPACE]

		else
			if isBracket @currentToken
				return [@currentToken, TokenType.BRACKET]
			else if isSquareBracket @currentToken
				return [@currentToken, TokenType.SQUARE_BRACKET]
			else if isCurlyBrace @currentToken
				return [@currentToken, TokenType.CURLY_BRACE]
			else
				return [@currentToken, TokenType.OTHER]



	parseOperator: ->
		@currentToken = @currentCharacter

		while @next? and isOperator @next
			@currentToken += @nextChar()
			@next = @peek()

		return [@currentToken, TokenType.OPERATOR]



	nextToken: ->
		@currentToken = ""
		return @parseMultiline() if @parseMultiline?
		@currentCharacter = @nextChar()
		@next = @peek()

		switch
			when isNumber(@currentCharacter) or (@currentCharacter is "." and isNumber @next) or (@currentCharacter is "-" and (@next is "." or isNumber @next))
				return @parseNumber()
			
			when isLetter(@currentCharacter) or isUnderscore(@currentCharacter)
				return @parseIdentifier()

			when @currentCharacter is "-" and @next is "-"
				return @parseComment()

			when @currentCharacter is "\"" or @currentCharacter is "'"
				return @parseString()

			when isOperator @currentCharacter
				return @parseOperator()

			when @currentCharacter?
				return @parseOther()

			else
				return ["", TokenType.EOF]



$(document).ready ->
	$("code").each ->
		$code = $(this)
		shouldHighlight = $code.data "should-highlight"
		source = $code.text()
		language = $code.data("language") or "plain"

		tokenizer = new Tokenizer source

		tokens = while (token = tokenizer.nextToken())[1] isnt TokenType.EOF
			token

		totalLineCount = tokenizer.lineNumber
		totalLineCountLength = totalLineCount.toString().length

		$parent = $code.parent()

		$parent.addClass "highlighted-code"

		$lineNumbers = $ "<code>"
		$lineNumbers.addClass "line-numbers"

		$highlightedCode = $ "<code>"
		$highlightedCode.addClass "code"

		currentLine = 1
		lineCount = 0

		indentation = 0

		tokens.push ["", TokenType.WHITESPACE]
		lastTokenType = null
		newLineAfterBracket = 1
		shouldHaveNewLine = no
		indentChangeThisLine = 0
		indentChangedThisLine = no
		isFirstLine = yes

		previousToken = ["\n", TokenType.OTHER]
		for token in tokens
			if isNewline previousToken[0]
				lineCount += 1
				$lineNumbers.append "\n" unless isFirstLine
				isFirstLine = no
				$lineNumbers.append lineCount

			text = token[0]
			type = token[1]

			$span = $ "<span>"
			$span.text text
			$span.addClass type.toLowerCase().replace "_", "-" if shouldHighlight

			$highlightedCode.append $span
			previousToken = token

		$code.after $lineNumbers
		$lineNumbers.after $highlightedCode

		$code.remove()