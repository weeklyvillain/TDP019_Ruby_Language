ALL_VARIABLES = [{}]

"""********** ASSIGN **********"""
class ASSIGN
	attr_accessor :type
	def initialize (variable_type, variable_name, variable_value, scope)
		@type = :ASSIGN
		@variable_type = variable_type
		@variable_name = variable_name
		@variable_value = variable_value
		@scope = scope
	end
	def val()
		ALL_VARIABLES[@scope][@variable_name] = Object.const_get(@variable_type).new(@variable_value)
	end
end

"""********** INTEGER **********"""
class INTEGER
	attr_accessor :value, :type
	def initialize (value)
		@value = value
		@type = :INT
	end
	def val()
		return @value
	end
end

"""********** FLOAT **********"""
class FLOAT
	attr_accessor :value, :type
	def initialize (value)
		@value = value
		@type = :FLOAT
	end
	def val()
		return @value
	end
end

"""********** CHAR **********"""
class CHAR
	attr_accessor :value, :type
	def initialize (value)
		@value = INTEGER.new(value.to_i)
		@type = :CHAR
	end
	def val()
		return @value.val().chr(Encoding::UTF_8)
	end
end

"""********** STRING **********"""
class STRING
	attr_accessor :value, :type
	def initialize (value)
		@value = INTEGER.new(value.to_i)
		@type = :STRING
	end
	def val()
		return @value.join('')
	end
end

"""********** BOOL **********"""
class BOOL
	attr_accessor :value,:type
	def initialize (value)
        @value = value
        @type = :BOOL
	end
	def val()
		return @value
	end
end
