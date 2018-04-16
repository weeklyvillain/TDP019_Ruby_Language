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
		else
			ALL_VARIABLES[@scope][@variable_name]
		end	
	end
end

"""class LOOKUP
    attr_accessor :variable_name, :starting_scope
    def initialize(variable_name, starting_scope)     
        @variable_name = variable_name
        @starting_scope = starting_scope;
    end
    def val(scope = @starting_scope)
        if ALL_VARIABLES[scope].key?(@variable_name)
            return ALL_VARIABLES[scope][@variable_name].val
        else
            if scope-1 >= 0
                self.val(scope-1)
            else
                return 
            end
        end
    end
end
"""

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