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
			@@all_variables[@scope][@variable_name] = Object.const_get(@variable_type).new(@variable_value)
			return @@all_variables[@scope][@variable_name]
		else
			puts("Trying to initialize a already existant variable!")
			return nil
		end
	end
end

class LOOKUP_VAR
	attr_accessor :variable_name, :starting_scope
	def initialize(variable_name, starting_scope)
		@variable_name = variable_name
		@starting_scope = starting_scope;
	end
	def val(scope = @starting_scope)
		if @@all_variables[scope].key?(@variable_name)
			previous = @@all_variables[scope][@variable_name]
			while true do
				if previous.val().respond_to?(:val)
					previous = previous.val()
				else
					return previous
				end
			end
		else
			if scope-1 >= 0
				self.val(scope-1)
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
			puts("Function does not exit!")
			return nil
			end
		end
	end



		"""Arithmetics"""

class ADD
	attr_accessor :value
	def initialize(a, b)
		@value1 = if a.is_a?(LOOKUP_VAR) then a.val() else a end
		@value2 = if b.is_a?(LOOKUP_VAR) then b.val() else b end
	end
	def to_s()
		return self.val().to_s()
	end
	def val()
		if @value1 != nil and @value2 != nil
			if @value1.is_a?(FLOAT_C) or @value2.is_a?(FLOAT_C)
				return FLOAT_C.new(@value1.val() + @value2.val())
			else
				return INTEGER_C.new(@value1.val() + @value2.val())
			end
		else
			return nil
		end
	end
end

class SUBTRACT
	attr_accessor :value
	def initialize(a, b)
		@value1 = if a.is_a?(LOOKUP_VAR) then a.val() else a end
		@value2 = if b.is_a?(LOOKUP_VAR) then b.val() else b end
	end
	def to_s()
		return self.val().to_s()
	end
	def val()
		if @value1 != nil and @value2 != nil
			if @value1.is_a?(FLOAT_C) or @value2.is_a?(FLOAT_C)
				return FLOAT_C.new(@value1.val() - @value2.val())
			else
				return INTEGER_C.new(@value1.val() - @value2.val())
			end
		else
			return nil
		end
	end
end

class MULTIPLY
	attr_accessor :value
	def initialize(a, b)
		@value1 = if a.is_a?(LOOKUP_VAR) then a.val() else a end
		@value2 = if b.is_a?(LOOKUP_VAR) then b.val() else b end
	end
	def to_s()
		return self.val().to_s()
	end

	def val()
		if @value1 != nil and @value2 != nil
			if @value1.is_a?(FLOAT_C) or @value2.is_a?(FLOAT_C)
				return FLOAT_C.new(@value1.val() * @value2.val())
			else
				return INTEGER_C.new(@value1.val() * @value2.val())
			end
		else
			return nil
		end
	end
end

class DIVIDE
	attr_accessor :value
	def initialize(a, b)
		@value1 = if a.is_a?(LOOKUP_VAR) then a.val() else a end
		@value2 = if b.is_a?(LOOKUP_VAR) then b.val() else b end
	end
	def to_s()
		return self.val().to_s()
	end
	def val()
		if @value1 != nil and @value2 != nil
			return FLOAT_C.new(@value1.val() / @value2.val())
		else
			return nil
		end
	end
end


		""" Containers """

""" *** STRING *** """
class STRING_C
	attr_accessor :value, :type
	def initialize(value)
		@value = Array.new()
		value.split('').each {|c| @value << CHAR_C.new(c)}
		@type = :STRING
	end
	def to_s()
		return self.val().to_s()
	end
	def val()
		return @value.map{|c| c.val()}.join('')
	end
end

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

class IF 
	attr_accessor :value, :type
	def initialize(value)
		@value = value
		@type = :STRING
	end
	def to_s()
		return self.val().to_s()
	end
	def val()
		
	end
end

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
		return BOOL_C.new(@value1.val() && @value2.val())
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
		return BOOL_C.new(@value1.val() || @value2.val())
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
		return BOOL_C.new(@value1.val() == @value2.val())
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
		while @condition do 
			r = @block.val()
		end 
		@@all_variables.pop()
		@@current_scope -= 1
		r
	end
end

