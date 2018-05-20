class TokenType
  BOOL_LITERAL = :TOKEN_BOOL_LITERAL
  INT_LITERAL = :TOKEN_INT_LITERAL
  STR_LITERAL = :TOKEN_STR_LITERAL
  ENDT = :TOKEN_END
  CONCEPT = :TOKEN_CONCEPT
  RULE = :TOKEN_RULE
  QUERY = :TOKEN_QUERY
  COMPARISON_OP = :COMPARISON_OP
  EQUALITY_OP = :EQUALITY_OP
  LOGIC_OP = :LOGIC_OP
  IDENTIFIER = :TOKEN_IDENTIFIER
end

class Token
  def initialize(type, value)
    @type = type
    @value = value
  end

  def to_s
    return "Token{type=#{type}, value=#{value}}"
  end

  attr_reader :type, :value
end

module Tokenizer
  INT_REG = /^[0-9]+$/
  STR_REG = /^"([^"]+)"$/
  QUERY_REG = /^query\[(.+)\]$/
  IDENTIFIER_REG = /^[A-Za-z][A-Za-z0-9_]{0,}$/

  def self.tokenize(_str)
    tokens = []
    symbols = _str.split(/\s+/)
    for symbol in symbols
      if is_bool(symbol)
        tokens.push(read_bool(symbol))
      elsif is_int(symbol)
        tokens.push(read_int(symbol))
      elsif is_string(symbol)
        tokens.push(read_string(symbol))
      elsif is_end(symbol)
        tokens.push(read_end(symbol))
      elsif is_concept(symbol)
        tokens.push(read_concept(symbol))
      elsif is_rule(symbol)
        tokens.push(read_rule(symbol))
      elsif is_query(symbol)
        tokens.push(read_query(symbol))
      elsif is_comparison_op(symbol)
        tokens.push(read_comparison_op(symbol))
      elsif is_equality_op(symbol)
        tokens.push(read_equality_op(symbol))
      elsif is_logic_op(symbol)
        tokens.push(read_logic_op(symbol))
      elsif is_identifier(symbol)
        tokens.push(read_identifier(symbol))
      else
        raise ArgumentError, "Invalid symbol #{symbol}."
      end
    end
    return tokens
  end

  def self.is_bool(symbol)
    Assertions.not_nil(symbol)
    return symbol == "true" || symbol == "false"
  end

  def self.read_bool(symbol)
    Assertions.check(is_bool(symbol))
    value = symbol == "true"
    return Token.new(TokenType::BOOL_LITERAL, value)
  end

  def self.is_int(symbol)
    return Assertions.not_nil(symbol) =~ INT_REG
  end

  def self.read_int(symbol)
    Assertions.check(is_int(symbol))
    return Token.new(TokenType::INT_LITERAL, symbol.to_i)
  end

  def self.is_string(symbol)
    return Assertions.not_nil(symbol) =~ STR_REG
  end

  def self.read_string(symbol)
    Assertions.check(is_string(symbol))
    value = symbol.match(STR_REG).captures[0]
    return Token.new(TokenType::STR_LITERAL, value)
  end

  def self.is_end(symbol)
    return Assertions.not_nil(symbol) == "end"
  end

  def self.read_end(symbol)
    Assertions.check(is_end(symbol))
    return Token.new(TokenType::ENDT, nil)
  end

  def self.is_concept(symbol)
    return Assertions.not_nil(symbol) == "concept"
  end

  def self.read_concept(symbol)
    Assertions.check(is_concept(symbol))
    return Token.new(TokenType::CONCEPT, nil)
  end

  def self.is_rule(symbol)
    return Assertions.not_nil(symbol) == "rule"
  end

  def self.read_rule(symbol)
    return Token.new(TokenType::RULE, nil)
  end

  def self.is_query(symbol)
    match = Assertions.not_nil(symbol).match(QUERY_REG)
    if match.nil?
      return false
    else
      return is_string(match.captures[0])
    end
  end

  def self.read_query(symbol)
    Assertions.check(is_query(symbol))
    match = symbol.match(QUERY_REG)
    value = match.captures[0]
    return Token.new(TokenType::QUERY, value[1, value.size - 2])
  end

  def self.is_comparison_op(symbol)
    return symbol == ">" || symbol == "<"
  end

  def self.read_comparison_op(symbol)
    Assertions.check(is_comparison_op(symbol))
    return Token.new(TokenType::COMPARISON_OP, symbol)
  end

  def self.is_equality_op(symbol)
    return symbol == "==" || symbol == "!="
  end

  def self.read_equality_op(symbol)
    Assertions.check(is_equality_op(symbol))
    return Token.new(TokenType::EQUALITY_OP, symbol)
  end

  def self.is_logic_op(symbol)
    return symbol == "||" || symbol == "&&"
  end

  def self.read_logic_op(symbol)
    Assertions.check(is_logic_op(symbol))
    return Token.new(TokenType::LOGIC_OP, symbol)
  end

  def self.is_identifier(symbol)
    return Assertions.not_nil(symbol) =~ IDENTIFIER_REG
  end

  def self.read_identifier(symbol)
    Assertions.check(is_identifier(symbol))
    return Token.new(TokenType::IDENTIFIER, symbol)
  end
end
