local function dict(something)
	local chars = {}
	local type = type(something)
	
	if type == "string" then
		for i in something:gmatch(".") do
			chars[i] = true
		end 
	elseif type == "table" then
		for i,v in something do
			chars[v] = true
		end
	end
	return chars
end


local keywords = dict({
	"func",
	"return",
	"else",
	"if",
	"while",
	"break",
	"for",
	"end",
	"||", -- or
	"&&", -- and
	"!!", -- not
})

local Booleans = dict{"True","False"}
local Null = "Null"
-- Remember, Regex is for child diddlers
local numbers = dict(".0123456789")
local validchars = dict("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZ_|&!")
local token_type = {
	NUMBER  = "T_NUMBER",
	KEYWORD = "T_KEYWORD",
	LPARAN  = "T_LPARAN",
	RPARAN  = "T_RPARAN",
	LBRACK  = "T_LBRACK",
	RBRACK  = "T_RBRACK",
	LCBRACK  = "T_LCBRACK",
	RCBRACK  = "T_RCBRACK",
	ASSIGN  = "T_ASSIGN",
	EQUALS  = "T_EQUALITY",
	PLUS    = "T_OPERATOR",
	MINUS   = "T_OPERATOR",
	MULT    = "T_OPERATOR",
	DIVIDE  = "T_OPERATOR",
	POW     = "T_OPERATOR",
	MOD     = "T_OPERATOR",
	IDENTIFIER = "T_IDENTIFY",
	STRING = "T_STRING",
	COMMA = "T_COMMA",
	BOOL = "T_BOOL",
	PERIOD = "T_PERIOD",
	NEWLINE = "T_NEWLINE",
	NULL = "T_NULL"
}

local token = {
	["+"] = token_type.PLUS,
	["-"] = token_type.MINUS,
	["*"] = token_type.MULT,
	["/"] = token_type.DIVIDE,
	["^"] = token_type.POW,
	["%"] = token_type.MOD,
	["("] = token_type.LPARAN,
	[")"] = token_type.RPARAN,
	["["] = token_type.LBRACK,
	["]"] = token_type.RBRACK,
	["{"] = token_type.LCBRACK,
	["}"] = token_type.RCBRACK,
	[","] = token_type.COMMA,
	["."] = token_type.PERIOD,
	["\n"] = token_type.NEWLINE
}

local lexer = {}
function lexer:new(code)
	local m = { }
	setmetatable(m,self)
	self.__index = self
	self.code = code
	self.pointer = 0
	self.current_character = ""
	return m
end


function lexer:next_char()
	self.pointer += 1
	self.current_character = self.code:sub(self.pointer,self.pointer)
end

function lexer:previous_char()
	self.pointer -= 1
	self.current_character = self.code:sub(self.pointer,self.pointer)
end

function lexer:lex()
	local tokens = {}
	while self.pointer <= #self.code do 
		lexer:next_char()
		if self.current_character == "@" then		
			repeat lexer:next_char() until self.current_character == "\n"
		elseif numbers[self.current_character] then -- number character
			table.insert(tokens, lexer:get_number())

		elseif self.current_character == "'" or self.current_character == '"' then
			table.insert(tokens, lexer:get_string())			

		elseif self.current_character == "=" then
			lexer:next_char()
			if self.current_character == "=" then
				table.insert(tokens, {token_type.EQUALS,""})
			elseif self.current_character == ">" then
				table.insert(tokens, {token_type.KEYWORD,"=>"})
			else
				table.insert(tokens, {token_type.ASSIGN,""})
				lexer:previous_char()				
			end
		elseif validchars[self.current_character] then
			table.insert(tokens, lexer:get_identifier())
		elseif token[self.current_character] ~= nil then
			local TokenType = token[self.current_character]
			table.insert(tokens, {TokenType, self.current_character})
		end
	end
	return tokens
end



function lexer:get_number()
	local number = ""

	while self.pointer <= #self.code do task.wait()
		if not numbers[self.current_character] then
			break
		end
		number ..= self.current_character
		lexer:next_char()
	end
	return {token_type.NUMBER,tonumber(number)}
end

function lexer:get_string()
	local string = ""
	while self.pointer <= #self.code do task.wait()
		lexer:next_char()
		if self.current_character == "'" or self.current_character == '"' then
			break
		end
		string  ..= self.current_character
	end
	return {token_type.STRING,string}
end

function lexer:get_identifier()
	local string = ""
	while self.pointer <= #self.code do task.wait()
		if not validchars[self.current_character] then
			break
		end
		string  ..= self.current_character
		lexer:next_char()
	end
	
	local Type = "IDENTIFIER"
	
	if keywords[string] then
		Type = "KEYWORD"
	elseif Booleans[string] then
		Type = "BOOL"
	elseif string == Null then
		Type = "NULL"
	end
	
	return {token_type[Type], string}
end

return lexer
