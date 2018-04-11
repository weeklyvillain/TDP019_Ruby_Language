$variables = {[]}

####################### Assignment ##############################
class ASSIGN
	attr_accessor :value, :type
	def initialize (value)
		@value = value
		@type = :INT
	end
	def val()
		return @value
	end
end

####################### INT ##############################
class INT
	attr_accessor :value, :type
	def initialize (value)
		@value = value
		@type = :INT
	end
	def val()
		return @value
	end
end

####################### FLOAT ##############################
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

####################### CHAR ##############################
class CHAR
	attr_accessor :value, :type
	def initialize (value)
		@value = INT.new(value.to_i)
		@type = :CHAR
	end
	def val()
		return @value.val().chr(Encoding::UTF_8)

	end
end

####################### STRING ##############################
class STRING
	attr_accessor :value, :type
	def initialize (value)
		@value = INT.new(value.to_i)
		@type = :STRING
	end
	def val()
		return @value.join('')
	end
end

####################### BOOL ##############################
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
