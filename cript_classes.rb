require_relative "cript_archetypes"

ALL_VARIABLES = [{}]
FUNCTIONS = [{}]


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
		if !ALL_VARIABLES[@scope].key?(@variable_name)
			ALL_VARIABLES[@scope][@variable_name] = Object.const_get(@variable_type).new(@variable_value)
			ALL_VARIABLES[@scope][@variable_name]
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
		if ALL_VARIABLES[scope].key?(@variable_name)
			previous = ALL_VARIABLES[scope][@variable_name]
			while true do
				if previous.val().respond_to?(:val)
					previous = previous.val()
				else
					return previous.val()
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
		@scope = 0
	end
	def val()
		FUNCTIONS[@scope][@func_name] = FUNCTION_C.new(@func_name, @params, @block)
		FUNCTIONS[@scope][@func_name]
	end
end

class LOOKUP_FUNC
	attr_accessor :func_name, :starting_scope
	def initialize(func_name, starting_scope)
		@func_name = func_name
		@starting_scope = starting_scope;
	end
	def val(scope = @starting_scope)
		if FUNCTIONS[scope].key?(@func_name)
			puts(FUNCTIONS[scope][@func_name].val)
			FUNCTIONS[scope][@func_name].val

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
	def val()
		return @value1 + @value2
	end
end

class SUBTRACT
	attr_accessor :value
	def initialize(a, b)
		@value1 = if a.is_a?(LOOKUP_VAR) then a.val() else a end
		@value2 = if b.is_a?(LOOKUP_VAR) then b.val() else b end
	end
	def val()
		return @value1 - @value2
	end
end

class MULTIPLY
	attr_accessor :value
	def initialize(a, b)
		@value1 = if a.is_a?(LOOKUP_VAR) then a.val() else a end
		@value2 = if b.is_a?(LOOKUP_VAR) then b.val() else b end
	end
	def val()
		return @value1 * @value2
	end
end

class DIVIDE
	attr_accessor :value
	def initialize(a, b)
		@value1 = if a.is_a?(LOOKUP_VAR) then a.val() else a end
		@value2 = if b.is_a?(LOOKUP_VAR) then b.val() else b end
	end
	def val()
		return @value1 / @value2
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
	def val()
		return @value.map{|c| c.val()}.join('')
	end
end

#"""********** ARRAY **********"""
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


""" *** FUNCTIONS *** """

class FUNCTION_C
	attr_accessor :value, :block
	def initialize(name, params, stmt_list)
		@self = name
		@params = params
		@block = stmt_list
	end

	def val()
		@block.val()

	end
end
