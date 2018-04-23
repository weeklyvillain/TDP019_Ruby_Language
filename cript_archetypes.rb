"""********** INTEGER **********"""
class INTEGER_C
	attr_accessor :value, :type
	def initialize(value)
		@value = value
		@type = :INT
	end
	def val()
		return @value
	end
end

"""********** FLOAT **********"""
class FLOAT_C
	attr_accessor :value, :type
	def initialize(value)
		@value = value
		@type = :FLOAT
	end
	def val()
		return @value
	end
end

"""********** CHAR **********"""
class CHAR_C
	attr_accessor :value, :type
	def initialize(value)
		@value = INTEGER_C.new(value.ord)
		@type = :CHAR
	end
	def val()
		return @value.val().chr()
	end
end

""" *** BOOL *** """
class BOOL_C
	attr_accessor :value,:type
	def initialize(value)
		@value = value
		@type = :BOOL
	end
	def val()
		return @value
	end
end

""" *** SUPER *** """
class SUPER_C
	attr_accessor :value,:type
	def initialize (value)
		@value = value
		@type = :SUPER
	end
	def val()
		return @value
	end
end
