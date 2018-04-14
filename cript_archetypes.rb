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
