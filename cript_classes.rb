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
			ALL_VARIABLES[@scope][@variable_name].val
		else
			print "ERROR! Re-initializing a Variable!"
		end
		
	end
end

class LOOKUP

    def initialize(variable_name, starting_scope)
        
    end
    def val()
    
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