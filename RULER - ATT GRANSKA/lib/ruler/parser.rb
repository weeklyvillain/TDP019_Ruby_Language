class TokenScanner
  def initialize(tokens)
    @tokens = Assertions.not_nil(tokens)
    @index = 0
    @saved_indices = []
  end

  def push
    @saved_indices.push(@index)
  end

  def pop
    @index = @saved_indices.pop
  end

  def get
    peek(0)
  end

  def get_t(type)
    return peek_t(0, type)
  end

  def consume(type)
    token = get
    Assertions.check_type(token, type)
    adv
    return token.value
  end

  def adv
    move(1)
  end

  def prev
    move(-1)
  end

  def move(offset)
    index = @index + offset
    Assertions.check(index >= 0 && index <= @tokens.size)
    @index = index
  end

  def peek(offset)
    index = @index + offset
    Assertions.check(index >= 0 && index < @tokens.size)
    return @tokens[index]
  end

  def peek_t(offset, type)
    return peek(offset).type == type
  end

  def reached_end
    return @index == @tokens.size
  end
end

class Parser
  def initialize(tokens)
    @tokens = tokens
    @scanner = TokenScanner.new(tokens)
  end

  def parse
    context = Context.new
    while !@scanner.reached_end
      if is_concept
        concept = parse_concept
        if context.concepts.key?(concept.name)
          raise SyntaxError, "Concept #{concept.name} already exists."
        end
        context.concepts[concept.name] = concept
      elsif is_rule
        rule = parse_rule
        if context.rules.key?(rule.name)
          raise SyntaxError, "Rule #{rule.name} already exists."
        end
        context.rules[rule.name] = rule
      else
        raise SyntaxError, "Unexpected token #{@scanner.get}."
      end
    end
    return context
  end

  def is_primary
    return is_literal || @scanner.get_t(TokenType::QUERY) ||
      @scanner.get_t(TokenType::IDENTIFIER)
  end

  def parse_primary
    Assertions.check(is_primary)
    token = @scanner.get
    if token.type == TokenType::BOOL_LITERAL ||
      token.type == TokenType::STR_LITERAL ||
      token.type == TokenType::INT_LITERAL
      return parse_literal
    elsif token.type == TokenType::QUERY
      @scanner.adv
      return QueryNode.new(token.value)
    else
      @scanner.adv
      return ConceptNode.new(token.value)
    end
  end

  def is_literal
    return @scanner.get_t(TokenType::BOOL_LITERAL) ||
      @scanner.get_t(TokenType::STR_LITERAL) ||
      @scanner.get_t(TokenType::INT_LITERAL)
  end

  def parse_literal
    Assertions.check(is_literal)
    token = @scanner.get
    node = LiteralObjNode.new(get_obj_type(token.type), token.value)
    @scanner.adv
    return node
  end

  def is_comparison_cond
    return is_primary && @scanner.peek_t(1, TokenType::COMPARISON_OP)
  end

  def parse_comparison_cond
    Assertions.check(is_comparison_cond)
    left = parse_primary
    op = @scanner.consume(TokenType::COMPARISON_OP)
    right = parse_primary
    return ComparisonNode.new(left, op, right)
  end

  def is_equality_cond
    return is_primary && @scanner.peek_t(1, TokenType::EQUALITY_OP)
  end

  def parse_equality_cond
    Assertions.check(is_equality_cond)
    left = parse_primary
    op = @scanner.consume(TokenType::EQUALITY_OP)
    right = parse_primary
    return EqualityNode.new(left, op, right)
  end

  def is_logic_cond
    @scanner.push
    flag = false
    if is_logic_cond_part
      parse_logic_cond_part
      if @scanner.get_t(TokenType::LOGIC_OP)
        flag = true
      end
    end
    @scanner.pop
    return flag
  end

  def parse_logic_cond
    Assertions.check(is_logic_cond)
    left = parse_logic_cond_part
    op = @scanner.consume(TokenType::LOGIC_OP)
    right = parse_logic_cond_part
    node = LogicNode.new(left, op, right)
    while @scanner.get_t(TokenType::LOGIC_OP)
      op = @scanner.consume(TokenType::LOGIC_OP)
      Assertions.check(is_logic_cond_part)
      right = parse_logic_cond_part
      node = LogicNode.new(node, op, right)
    end
    return node
  end

  def is_logic_cond_part
    return is_comparison_cond || is_equality_cond || is_primary
  end

  def parse_logic_cond_part
    if is_comparison_cond
      return parse_comparison_cond
    elsif is_equality_cond
      return parse_equality_cond
    elsif is_primary
      return parse_primary
    else
      raise ArgumentError, "Not a logic condition part."
    end
  end

  def is_conditional
    return is_logic_cond || is_comparison_cond || is_equality_cond || is_primary
  end

  def parse_conditional
    Assertions.check(is_conditional)
    if is_logic_cond
      condition = parse_logic_cond
    elsif is_comparison_cond
      condition = parse_comparison_cond
    elsif is_equality_cond
      condition = parse_equality_cond
    elsif is_primary
      condition = parse_primary
    else
      raise ArgumentError, "Invalid conditional."
    end
    return ConditionalNode.new(condition)
  end

  def is_concept
    return @scanner.get_t(TokenType::CONCEPT) &&
      @scanner.peek_t(1, TokenType::IDENTIFIER)
  end

  def parse_concept
    Assertions.check(is_concept)
    @scanner.consume(TokenType::CONCEPT)
    name = @scanner.consume(TokenType::IDENTIFIER)

    Assertions.check(is_conditional)
    condition = parse_conditional
    @scanner.consume(TokenType::ENDT)
    return Concept.new(name, condition)
  end

  def is_action
    return @scanner.get_t(TokenType::IDENTIFIER)
  end

  def parse_action
    Assertions.check(is_action)
    action = @scanner.consume(TokenType::IDENTIFIER)
    arguments = []
    while is_literal
      arguments.push(parse_literal)
    end
    return ActionNode.new(action, arguments)
  end

  def is_rule
    return @scanner.get_t(TokenType::RULE) &&
      @scanner.peek_t(1, TokenType::IDENTIFIER)
  end

  def parse_rule
    Assertions.check(is_rule)
    @scanner.consume(TokenType::RULE)
    name = @scanner.consume(TokenType::IDENTIFIER)
    Assertions.check(is_conditional)
    condition = parse_conditional
    actions = []
    while is_action
      actions.push(parse_action)
    end
    @scanner.consume(TokenType::ENDT)
    return Rule.new(name, condition, actions)
  end

  def get_obj_type(token_type)
    Assertions.not_nil(token_type)
    if token_type == TokenType::BOOL_LITERAL
      return ObjType::BOOL
    elsif token_type == TokenType::STR_LITERAL
      return ObjType::STR
    elsif token_type == TokenType::INT_LITERAL
      return ObjType::INT
    else
      raise ArgumentError, "Cannot map token type to object type."
    end
  end
end

def build_context(filename)
  code = File.read(filename)
  tokens = Tokenizer.tokenize(code)
  parser = Parser.new(tokens)
  return parser.parse
end
