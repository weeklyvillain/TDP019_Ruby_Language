require_relative "cript_archetypes"

##############################################################################
#
#						 Classes for the Cript++ Language
#
# 					Built by Jimbj685 and Filer358 in 05/2018
#
##############################################################################

$all_variables = [{}]
$functions = [{}]
$current_scope = 0
$return_values = {}

#""" Variable Handling """

#""" *** ASSIGN and LOOKUP *** """

class ASSIGN_VAR
	attr_accessor :type, :variable_type, :variable_name, :variable_value
	def initialize (variable_type, variable_name, variable_value)
		@type = :ASSIGN_VAR
		@variable_type = variable_type
		@variable_name = variable_name
		@variable_value = variable_value
	end

	def val(scope = $current_scope)
		if !$all_variables[scope].has_key?(@variable_name)
			$all_variables[scope][@variable_name] = variable_value
			return $all_variables[scope][@variable_name]
		else
			raise ArgumentError.new("Trying to initialize " + @variable_name + " which is an already existant variable!")
		end
	end
end

class LOOKUP_VAR
	attr_accessor :variable_name, :type
	def initialize(variable_name)
		@variable_name = variable_name
		@type = :LOOKUP_VAR
	end

	def val(scope = $current_scope)
		if $all_variables[scope].has_key? @variable_name then
			variable = $all_variables[scope][@variable_name]
			if variable.is_a? LOOKUP_VAR then
				variable = variable.val()
				while variable.is_a? LOOKUP_VAR
					variable = variable.val()
				end
				return variable.val()
			else
				return variable.val()
			end
		else
			if scope-1 >= 0
				return self.val(scope-1)
			else
				raise ArgumentError.new("Variable " + @variable_name + " does not exist!")
			end
		end
	end
end

class RE_VAR
	attr_accessor :type, :variable_type, :variable_name, :variable_value
	def initialize (variable_name, variable_value)
		@type = :RE_VAR
		@variable_name = variable_name
		@variable_value = variable_value
	end

	def val(scope = $current_scope)
		if $all_variables[scope].has_key?(@variable_name) then
			value = @variable_value.val()
			r = $all_variables[scope][@variable_name].value = value.value
			return r
		else
			if scope-1 >= 0
				return self.val(scope-1)
			else
				raise ArgumentError.new("Variable " + @variable_name + " does not exist!")
			end
		end
	end
end

class ASSIGN_FUNC
	attr_accessor :type, :func_name, :params, :block, :scope
	def initialize (func_name, params, stmt_list)
		@type = :ASSIGN_FUNC
		@func_name = func_name
		@params = params
		@block = stmt_list
	end

	def val()
		$functions[$current_scope][@func_name] = FUNCTION_C.new(@func_name, @params, @block)
		$functions[$current_scope][@func_name]
	end
end

class LOOKUP_FUNC
	attr_accessor :func_name
	def initialize(func_name, params)
		@func_name = func_name
		@params = params
	end

	def val(scope = $current_scope)
		if $functions[scope].has_key? @func_name
			function = $functions[scope][@func_name]
			if function.is_a? LOOKUP_FUNC then
				function = function.val()
				while function.is_a? LOOKUP_FUNC
					function = function.val()
				end
				return function.val(@params).val
			else
				return function.val(@params)
			end	
		else
			if scope-1 >= 0
				self.val(scope-1)
			else
				raise ArgumentError.new("Function " + @func_name + " does not exist!")
				return nil
			end
		end
	end
end

######    Arithmetics    #####

class ADD
	attr_accessor :value
	def initialize(a, b)
		@value1 = a
		@value2 = b
		@value = 0
	end

	def val()
		if @value1 != nil and @value2 != nil
			@value1 = @value1.val()
			@value2 = @value2.val()
			if @value1.is_a?(FLOAT_C) and @value2.is_a?(FLOAT_C)
				@value = FLOAT_C.new(@value1+@value2)
				return @value
			elsif @value1.is_a?(INTEGER_C) and @value2.is_a?(INTEGER_C)
				@value = INTEGER_C.new(@value1+@value2)
				return @value
			else
				raise TypeError
			end
		else
			return nil
		end
	end
end

class SUBTRACT
	attr_accessor :value
	def initialize(a, b)
		@value1 = a
		@value2 = b
		@value = 0
	end

	def val()
		if @value1 != nil and @value2 != nil
			@value1 = @value1.val()
			@value2 = @value2.val()
			if @value1.is_a?(FLOAT_C) and @value2.is_a?(FLOAT_C)
				@value = FLOAT_C.new(@value1-@value2)
				return @value
			elsif @value1.is_a?(INTEGER_C) and @value2.is_a?(INTEGER_C)
				@value = INTEGER_C.new(@value1-@value2)
				return @value
			else
				raise TypeError
			end
		else
			return nil
		end
	end
end

class MULTIPLY
	attr_accessor :value
	def initialize(a, b)
		@value1 = a
		@value2 = b
		@value = 0
	end

	def val()
		if @value1 != nil and @value2 != nil
			@value1 = @value1.val()
			@value2 = @value2.val()
			if @value1.is_a?(FLOAT_C) and @value2.is_a?(FLOAT_C)
				@value = FLOAT_C.new(@value1*@value2)
				return @value
			elsif @value1.is_a?(INTEGER_C) and @value2.is_a?(INTEGER_C)
				@value = INTEGER_C.new(@value1*@value2)
				return @value
			else
				raise TypeError
			end
		else
			return nil
		end
	end
end

class DIVIDE
	attr_accessor :value
	def initialize(a, b)
		@value1 = a
		@value2 = b
		@value = 0
	end

	def val()
		if @value1 != nil and @value2 != nil
			@value1 = @value1.val()
			@value2 = @value2.val()
			if @value1.is_a?(FLOAT_C) and @value2.is_a?(FLOAT_C)
				@value = FLOAT_C.new(@value1/@value2)
				return @value
			elsif @value1.is_a?(INTEGER_C) and @value2.is_a?(INTEGER_C)
				@value = INTEGER_C.new(@value1/@value2)
				return @value
			else
				raise TypeError
			end
		else
			return nil
		end
	end
end

#####    Random     #####
class RAND_INT
	attr_accessor :value
	def initialize(start, stop)
		@value = 0
		if start.is_a?(INTEGER_C) and stop.is_a?(INTEGER_C)
			@start = start
			@stop = stop
		else
			raise TypeError
		end
	end

	def val()
		return INTEGER_C.new(rand(@start.val().value...@stop.val().value))
	end
end

class RAND_FLOAT
	attr_accessor :value
	def initialize(start, stop)
		@value = 0
		if start.is_a?(FLOAT_C) and stop.is_a?(FLOAT_C)
			@start = start
			@stop = stop
		else
			raise TypeError
		end
	end

	def val()
		return FLOAT_C.new(rand(@start.val().value...@stop.val().value))
	end
end

#""" *** COMPARISONS *** """

class IF_C
	attr_accessor :type
	def initialize(condition, stmt_list, else_stmt_list)
		@condition = condition
		@block1 = stmt_list
		@block2 = else_stmt_list
		@type = :STRING
	end

	def val()
		if @condition.val().value then
			return @block1.val()
		else
			if @block2 != nil then
				return @block2.val()
			else
				return nil
			end
		end
	end
end

#""" *** OPERATORS *** """

class AND_C
	def initialize(value1, value2)
		@value1 = value1
		@value2 = value2
		@type = :AND
	end

	def val()
		return BOOL_C.new(@value1.val().value && @value2.val().value)
	end
end

class OR_C
	def initialize(value1, value2)
		@value1 = value1
		@value2 = value2
		@type = :OR
	end

	def val()
		return BOOL_C.new(@value1.val().value || @value2.val().value)
	end
end

class EQUALS_C
	def initialize(value1, value2)
		@value1 = value1
		@value2 = value2
		@type = :EQUALS
	end

	def val()
		return BOOL_C.new(@value1.val().value == @value2.val().value)
	end
end

class NOT_C
	def initialize(name)
		@variable_name = name
	end

	def val()
		return BOOL_C.new(!@variable_name.val())
	end
end

#""" *** Loops *** """
class WHILE_C
	attr_accessor :value, :type
	def initialize(stmt_list, condition)
		@block = stmt_list
		@condition = condition
		@type = :WHILE
	end

	def val()
		$all_variables.push({})
		$current_scope += 1
		while @condition.val().value do
			r = @block.val()
		end
		$all_variables.pop()
		$current_scope -= 1
		r
	end
end

#""" *** built-in *** """

class ARRAY_C
	attr_accessor :value, :type
	def initialize(array_list, type = array_list[0].class)
		@value = array_list
		@type = :ARRAY
	end

	def val()
		return self
	end
end

class RE_ARRAY_C
	attr_accessor :value, :type
	def initialize(array_name, index, new_value)
		@array_name = array_name
		@index = index
		@value = new_value
		@type = :RE_ARRAY
	end

	def val(scope = $current_scope)
		if $all_variables[scope][@array_name] != nil then
			$all_variables[scope][@array_name].value[@index.val().value] = @value
			return $all_variables[scope][@array_name].value[@index.val().value]
		else
			return self.val(scope-1)
		end
	end
end

class GET_ARRAY_C
	attr_accessor :value, :type
	def initialize(array_name, index)
		@variable_name = array_name
		@value = nil
		@index = index
		@type = :GET_ARRAY
	end

	def val(scope = $current_scope)
		if $all_variables[scope][@variable_name] != nil then
			@value = $all_variables[scope][@variable_name].value[@index.val().value]
			return @value
		else
			return self.val(scope-1)
		end
	end
end

class PRINT_C
	def initialize(expr)
		@expr = expr
	end

	def val()
		r = @expr.val
		if(r != nil)
			print(r.value, "\n")
			r
		end
	end
end

class ReturnException < StandardError
	attr_accessor :object  
	def initialize(object = nil)
		self.object = object
	end
end
  

class RETURN_C
	attr_accessor :value, :type
	def initialize(value)
		@value = value
		@type = :RETURN
	end

	def val()
		@value = @value.val()
		raise ReturnException.new(@value)
	end
end

class RUN_C
	def initialize(arg)
		@arg = arg
	end

	def val()
		parser = Cript.new
		parser.log(false)
		file = File.open(@arg.val().value, "r")
		$all_variables.push({})
		$functions.push({})
		$current_scope += 1
		begin
			r = parser.parser(file.read)
			$all_variables.pop()
			$functions.pop()
			$current_scope -= 1
			return r
		rescue ReturnException => e
			return e.object.val()
		end
	end
end

class WAIT_C
	def initialize(time)
		@time = time.val().value
	end

	def val()
		sleep(@time)
		return self
	end
end
