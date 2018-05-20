class ObjType
  STR = :OBJ_STR
  INT = :OBJ_INT
  BOOL = :OBJ_BOOL
  TYPES = [STR, INT, BOOL]
end

class Obj
  def initialize(type, value)
    unless ObjType::TYPES.include?(Assertions.not_nil(type))
      raise SyntaxError, "Invalid type #{type}"
    end
    @type = type
    @value = Assertions.not_nil(value)
  end

  def self.to_rlr(value)
    if value.instance_of?(String)
      return self.str(value)
    elsif value.instance_of?(Integer)
      return self.int(value)
    elsif [true, false].include?(value)
      return self.bool(value)
    else
      raise SyntaxError, "Could not map value #{value} to ruler object."
    end
  end

  def self.to_ruby(obj)
    Assertions.check(obj.instance_of?(Obj))
    return obj.value
  end

  def self.bool(value)
    Assertions.check(value == true || value == false)
    return Obj.new(ObjType::BOOL, value)
  end

  def self.true
    return bool(true)
  end

  def self.false
    return bool(false)
  end

  def self.int(value)
    return Obj.new(ObjType::INT, value)
  end

  def self.str(value)
    return Obj.new(ObjType::STR, value)
  end

  def self.less_than(left, right)
    Assertions.is_obj(left, ObjType::INT)
    Assertions.is_obj(right, ObjType::INT)
    return Obj.bool(left.value < right.value)
  end

  def self.greater_than(left, right)
    Assertions.is_obj(left, ObjType::INT)
    Assertions.is_obj(right, ObjType::INT)
    return Obj.bool(left.value > right.value)
  end

  def self.equal(left, right)
    Assertions.check(left.type == right.type)
    return Obj.bool(left.value == right.value)
  end

  def self.not_equal(left, right)
    Assertions.check(left.type == right.type)
    return Obj.bool(left.value != right.value)
  end

  def self.and(left, right)
    Assertions.is_obj(left, ObjType::BOOL)
    Assertions.is_obj(right, ObjType::BOOL)
    return Obj.bool(left.value && right.value)
  end

  def self.or(left, right)
    Assertions.is_obj(left, ObjType::BOOL)
    Assertions.is_obj(right, ObjType::BOOL)
    return Obj.bool(left.value || right.value)
  end
  attr_accessor :type, :value
end

class SyntaxNode
  def execute(context)
    raise NotImplementedError
  end
end

class LiteralObjNode
  def initialize(type, value)
    @type = Assertions.not_nil(type)
    @value = Assertions.not_nil(value)
  end

  def execute(context)
    return Obj.new(@type, @value)
  end
end

class QueryNode
  def initialize(key)
    @key = Assertions.not_nil(key)
  end

  def execute(context)
    unless context.facts.key?(@key)
      raise SyntaxError, "The fact hash does not contain key #{@key}."
    end
    return context.facts[@key]
  end
end

class ConceptNode
  def initialize(name)
    @name = Assertions.not_nil(name)
  end

  def execute(context)
    unless context.concepts.key?(@name)
      raise SyntaxError, "No concept named #{@name} exists."
    end
    return context.concepts[@name].condition.execute(context)
  end
end

class ComparisonNode
  def initialize(left, op, right)
    Assertions.check(op == "<" || op = ">")
    @left = Assertions.not_nil(left)
    @op = op
    @right = Assertions.not_nil(right)
  end

  def execute(context)
    left_val = @left.execute(context)
    right_val = @right.execute(context)
    if @op == "<"
      return Obj.less_than(left_val, right_val)
    else
      return Obj.greater_than(left_val, right_val)
    end
  end
end

class EqualityNode
  def initialize(left, op, right)
    Assertions.check(op == "==" || op == "!=")
    @left = Assertions.not_nil(left)
    @op = op
    @right = Assertions.not_nil(right)
  end

  def execute(context)
    left_val = @left.execute(context)
    right_val = @right.execute(context)
    if @op == "=="
      return Obj.equal(left_val, right_val)
    else
      return Obj.not_equal(left_val, right_val)
    end
  end
end

class LogicNode
  def initialize(left, op, right)
    Assertions.check(op == "&&" || op == "||")
    @left = Assertions.not_nil(left)
    @op = op
    @right = Assertions.not_nil(right)
  end

  def execute(context)
    left_val = @left.execute(context)
    right_val = @right.execute(context)
    if @op == "&&"
      return Obj.and(left_val, right_val)
    else
      return Obj.or(left_val, right_val)
    end
  end
end

class ConditionalNode
  def initialize(condition)
    @condition = Assertions.not_nil(condition)
  end

  def execute(context)
    value = @condition.execute(context)
    Assertions.is_obj(value, ObjType::BOOL)
    return value
  end
end

class ActionNode
  def initialize(action, arguments)
    @action = action
    @arguments = arguments
  end

  def execute(context)
    unless context.actions.key?(@action)
      raise SyntaxError, "No action with name \"#{@action}\" exists."
    end
    converted = []
    @arguments.each do |arg|
      converted.push(Obj.to_ruby(arg.execute(context)))
    end
    context.actions[@action].call(*converted)
  end
end

class Concept
  def initialize(name, condition)
    @name = Assertions.not_nil(name)
    @condition = Assertions.not_nil(condition)
  end
  attr_reader :name, :condition
end

class Rule
  def initialize(name, condition, actions)
    @name = Assertions.not_nil(name)
    @condition = Assertions.not_nil(condition)
    @actions = Assertions.not_nil(actions)
  end
  attr_reader :name, :condition, :actions
end

class Context
  def initialize
    @concepts = {}
    @rules = {}
    @facts = {}
    @actions = {}
  end

  def execute
    @rules.each do |name, rule|
      bool = rule.condition.execute(self)
      if bool.type == ObjType::BOOL && bool.value
        rule.actions.each do |action|
          action.execute(self)
        end
      end
    end
  end

  attr_reader :concepts, :rules, :facts, :actions
end
