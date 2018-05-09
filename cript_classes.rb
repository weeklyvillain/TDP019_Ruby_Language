require_relative "cript_archetypes"

@@all_variables = [{}]
@@functions = [{}]
@@current_scope = 0
@@base_scope = 0

		""" Variable Handling """

""" *** ASSIGN and LOOKUP *** """

class ASSIGN_VAR
	attr_accessor :type, :variable_type, :variable_name, :variable_value, :scope
	def initialize (variable_type, variable_name, variable_value, scope)
		@type = :ASSIGN_VAR
		@variable_type = variable_type
		@variable_name = variable_name
		@variable_value = variable_value
		@scope = scope
	end
	def val()
		if !@@all_variables[@scope].key?(@variable_name)
			@@all_variables[@scope][@variable_name] = @variable_value
			return @@all_variables[@scope][@variable_name]
		else
			puts("Trying to initialize a already existant variable!")
			return nil
		end
	end
end

class LOOKUP_VAR
	attr_accessor :variable_name, :starting_scope, :type
	def initialize(variable_name, starting_scope)
		@variable_name = variable_name
		@starting_scope = starting_scope;
		@type = :LOOKUP_VAR
	end
	def to_s
		return self.val()
	end
	def val(scope = @@current_scope)
		if @@all_variables[scope][@variable_name] != nil then
			variable = @@all_variables[scope][@variable_name]
			if variable.is_a? LOOKUP_VAR then
				variable = variable.val()
				while variable.is_a? LOOKUP_VAR
					variable = variable.val()
				end
				return variable
			else
				return variable.val()
			end
		else
			if scope-1 >= 0
				return self.val(scope-1)
			else
				puts("Variable does not exit!")
				return nil
			end
		end
	end
end

class RE_VAR
	attr_accessor :type, :variable_type, :variable_name, :variable_value, :scope
	def initialize (variable_name, variable_value, scope)
		@type = :RE_VAR
		@variable_name = variable_name
		@variable_value = variable_value
		@scope = scope
	end
	def val(scope = @@current_scope)
		if @@all_variables[scope].has_key?(@variable_name) then
			old_variable = @@all_variables[scope][@variable_name].val()
			value = @variable_value.val()
			r = @@all_variables[scope][@variable_name].value = value.value
			return r
		else
			if scope-1 >= 0
				return self.val(scope-1)
			else
				puts("Variable does not exit!")
				return nil
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
		@@functions[@@current_scope][@func_name] = FUNCTION_C.new(@func_name, @params, @block)
		@@functions[@@current_scope][@func_name]
	end
end

class LOOKUP_FUNC
	attr_accessor :func_name, :starting_scope
	def initialize(func_name, starting_scope, params)
		@func_name = func_name
		@starting_scope = starting_scope
		@params = params
	end
	def val(scope = @starting_scope)
		if @@functions[scope].key?(@func_name)
			@@functions[scope][@func_name].val(@params)
		else
			if scope-1 >= 0
				self.val(scope-1)
			else
				puts("Function does not exit!")
				return nil
			end
		end
	end
end
		"""Arithmetics"""

class ADD
	attr_accessor :value
	def initialize(a, b)
		@value1 = a
		@value2 = b
		@value = 0
	end
	def to_s()
		return self.val().to_s()
	end
	def val()
		if @value1 != nil and @value2 != nil
			if @value1.is_a?(FLOAT_C) or @value2.is_a?(FLOAT_C)
				@value = FLOAT_C.new(@value1.val()+@value2.val())
				return @value
			else
				@value = INTEGER_C.new(@value1.val()+@value2.val())
				return @value
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
	def to_s()
		return self.val().to_s()
	end
	def val()
		if @value1 != nil and @value2 != nil
			if @value1.is_a?(FLOAT_C) or @value2.is_a?(FLOAT_C)
				@value = FLOAT_C.new(@value1.val()-@value2.val())
				return @value
			else
				return INTEGER_C.new(@value1.val()-@value2.val())
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
	def to_s()
		return self.val().to_s()
	end

	def val()
		if @value1 != nil and @value2 != nil
			if @value1.is_a?(FLOAT_C) or @value2.is_a?(FLOAT_C)
				@value = FLOAT_C.new(@value1.val()*@value2.val())
				return @value
			else
				@value = INTEGER_C.new(@value1.val()*@value2.val())
				return @value
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
	def to_s()
		return self.val().to_s()
	end
	def val()
		if @value1 != nil and @value2 != nil
			return FLOAT_C.new(@value1.val()/@value2.val())
		else
			return nil
		end
	end
end


		""" Containers """



""" *** ARRAY *** """
class ARRAY
	attr_accessor :value, :type
	def initialize(value)
		@value = Array.new(value.split('').each {|c| CHAR.new(c)})
		@type = :STRING
	end
	def val(key)
		return @value.each{|c| c.val()}.join('')
	end
end


""" *** COMPARISONS *** """

class IF_C
	attr_accessor :type
	def initialize(condition, stmt_list, else_stmt_list)
		@condition = condition
		@block1 = stmt_list
		@block2 = else_stmt_list
		@type = :STRING
	end
	def to_s()
		return self.val().to_s()
	end
	def val()
		@@all_variables.push({})
		@@current_scope += 1
		if @condition.val().value then
			r = @block1.val()
		else
			if @block2 != nil then
				r = @block2.val()
			else
				r = nil
			end
		end
		@@all_variables.pop()
		@@current_scope -= 1
		r

	end
end

""" *** OPERATORS *** """

class AND_C
	def initialize(value1, value2)
		@value1 = value1
		@value2 = value2
		@type = :AND
	end
	def to_s()
		return self.val().to_s()
	end
	def val()
		return BOOL_C.new(@value1.value && @value2.value)
	end
end

class OR_C
	def initialize(value1, value2)
		@value1 = value1
		@value2 = value2
		@type = :OR
	end
	def to_s()
		return self.val().to_s()
	end
	def val()
		return BOOL_C.new(@value1.value || @value2.value)
	end
end

class EQUALS_C
	def initialize(value1, value2)
		@value1 = value1
		@value2 = value2
		@type = :EQUALS
	end
	def to_s()
		return self.val().to_s()
	end
	def val()
		return BOOL_C.new(@value1.val().value == @value2.val().value)
	end
end


""" *** Loops *** """
class WHILE_C
	attr_accessor :value, :type
	def initialize(stmt_list, condition)
		@block = stmt_list
		@condition = condition
		@type = :WHILE
	end

	def val()
		@@all_variables.push({})
		@@current_scope += 1
		while @condition.val().value do
			r = @block.val()
		end
		@@all_variables.pop()
		@@current_scope -= 1
		r
	end
end

""" *** RETURN *** """

class RETURN_C
	attr_accessor :value, :type
	def initialize(value)
		@value = value
		@type = :RETURN
	end

	def val()
		@value.val()
	end
end
