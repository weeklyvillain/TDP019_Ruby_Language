"""********** INTEGER **********"""
class INTEGER_C
	attr_accessor :value, :type
	def initialize(value)
		@value = value
		@type = :INT
	end
	def +(y)
		return @value + y.value
	end
	def -(y)
		return @value - y.value
	end
	def *(y)
		return @value * y.value
	end
	def /(y)
		return @value / y.value
	end

	def to_s()
		return value.to_s()
	end
	def val()
		return self
	end
end

"""********** FLOAT **********"""
class FLOAT_C
	attr_accessor :value, :type
	def initialize(value)
		@value = value
		@type = :FLOAT
	end
	def +(y)
		return @value + y.value
	end
	def -(y)
		return @value - y.value
	end
	def *(y)
		return @value * y.value
	end
	def /(y)
		return @value / y.value
	end

	def to_s()
		return value.to_s()
	end
	def val()
		return self
	end
end

"""********** CHAR **********"""
class CHAR_C
	attr_accessor :value, :type
	def initialize(value)
		@value = INTEGER_C.new(value.ord)
		@type = :CHAR
	end
	def to_s()
		return value.chr().to_s()
	end
	def val()
		return self
	end
end

""" *** STRING *** """
class STRING_C
	attr_accessor :value, :type
	def initialize(value)
		@value = value
		@type = :STRING
	end
	def to_s()
		return value.to_s()
	end
	def val()
		return self
	end
end

""" *** BOOL *** """
class BOOL_C
	attr_accessor :value,:type
	def initialize(value)
		@value = value
		@type = :BOOL
	end

	def to_s()
		return value.to_s()
	end
	def val()
		return self
	end
end

""" *** SUPER *** """
class SUPER_C
	attr_accessor :value,:type
	def initialize (value)
		@value = value
		@type = :SUPER
	end
	def to_s()
		return  @value.to_s()
	end
	def val()
		return self
	end
end

""" *** FUNCTIONS *** """

class FUNCTION_C
	attr_accessor :value, :block, :params
	def initialize(name, params, stmt_list)
		@self = name
		@params = params
		@block = stmt_list
	end
	# def to_s()
	# 	return self.val().to_s()
	# end
	def val(params = nil)
		@@all_variables.push({})
		@@current_scope += 1
		if params != nil
			 (-1..@params.length - 1).each { |i|
					@@all_variables[@@current_scope][@params[i][0]] = params[i]
				}
		end
		r = @block.val()
		@@all_variables.pop()
		@@current_scope -= 1
		r
	end
end

class STMTLIST_C
	attr_accessor :stmt, :stmt_list
	def initialize(stmt, stmt_list)
		@stmt = stmt
		@stmt_list = stmt_list
	end
	def to_s()
		self.val()
	end
	def val()
		r = @stmt.val()
		if @stmt_list != nil
			@stmt_list.val()
		else
			return r
		end
	end
end
