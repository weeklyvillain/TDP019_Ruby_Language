require_relative "cript_archetypes"

ALL_VARIABLES = [{}]

        """ Variable Handling """

"""********** ASSIGN **********"""
class ASSIGN
	attr_accessor :type, :variable_type, :variable_name, :variable_value, :scope
	def initialize (variable_type, variable_name, variable_value, scope)
		@type = :ASSIGN
		@variable_type = variable_type
		@variable_name = variable_name
		@variable_value = variable_value
		@scope = scope
	end
	def val()
		if !ALL_VARIABLES[@scope].key?(@variable_name)
			ALL_VARIABLES[@scope][@variable_name] = Object.const_get(@variable_type).new(@variable_value)
			ALL_VARIABLES[@scope][@variable_name]
		end	
	end
end

class LOOKUP
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


		"""Arithmetics"""

class ADD
	attr_accessor :value
	def initialize(a, b)
		@value1 = if a.is_a?(LOOKUP) then a.val() else a end
		@value2 = if b.is_a?(LOOKUP) then b.val() else b end
	end
	def val()
		return @value1 + @value2
	end
end
class SUBTRACT
	attr_accessor :value
	def initialize(a, b)
		@value1 = if a.is_a?(LOOKUP) then a.val() else a end
		@value2 = if b.is_a?(LOOKUP) then b.val() else b end
	end
	def val()
		return @value1 - @value2
	end
end
class MULTIPLY
	attr_accessor :value
	def initialize(a, b)
		@value1 = if a.is_a?(LOOKUP) then a.val() else a end
		@value2 = if b.is_a?(LOOKUP) then b.val() else b end
	end
	def val()
		return @value1 * @value2
	end
end
class DIVIDE
	attr_accessor :value
	def initialize(a, b)
		@value1 = if a.is_a?(LOOKUP) then a.val() else a end
		@value2 = if b.is_a?(LOOKUP) then b.val() else b end
	end
	def val()
		return @value1 / @value2
	end
end


        """ Containers """

"""********** STRING **********"""
class STRING_C
	attr_accessor :value, :type
	def initialize (value)
        @value = Array.new()
        value.split('').each {|c| @value << CHAR_C.new(c)}
		@type = :STRING
	end
	def val()
		return @value.map{|c| c.val()}.join('')
	end
end

#"""********** ARRAY **********"""
#class ARRAY
#	attr_accessor :value, :type
#	def initialize (value)
#		@value = Array.new(value.split('').each {|c| CHAR.new(c)})
#		@type = :STRING
#	end
#	def val()
#		return @value.each{|c| c.val()}.join('')
#	end
#end