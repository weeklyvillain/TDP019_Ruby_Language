##############################################################################
#
#					Archetype classes for the Cript++ Language
#
# 					Built by Jimbj685 and Filer358 in 05/2018
#
##############################################################################


#""********** INTEGER **********"""
class INTEGER_C
	attr_accessor :value, :type
	def initialize(value)
		if value.is_a?(Integer)
			@value = value
		else
			raise TypeError
		end
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

	def val()
		return self
	end
end

#"""********** FLOAT **********"""
class FLOAT_C
	attr_accessor :value, :type
	def initialize(value)
		if value.is_a?(Float)
			@value = value
		else
			raise TypeError
		end
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

	def val()
		return self
	end
end

#""" *** STRING *** """
class STRING_C
	attr_accessor :value, :type
	def initialize(value)
		if value.is_a?(String)
			@value = value
		else
			raise TypeError
		end
		@type = :STRING
	end

	def val()
		return self
	end
end

#""" *** BOOL *** """
class BOOL_C
	attr_accessor :value,:type
	def initialize(value)
		if value.is_a?(FalseClass) or value.is_a?(TrueClass)
			@value = value
		else
			raise TypeError
		end
		@type = :BOOL
	end

	def val()
		return self
	end
end


#""" *** FUNCTIONS *** """

class FUNCTION_C
	attr_accessor :value, :block, :params
	def initialize(name, params, stmt_list)
		@self = name
		@params = params
		@block = stmt_list
	end

	def val(params = nil)
		@@all_variables.push({})
		@@current_scope += 1
		if params != nil
			 (-1..@params.length - 1).each { |i|
					@@all_variables[@@current_scope][@params[i][0]] = params[i]
				}
		end
		r = @block
		r = r.val()

		@@all_variables.pop()
		@@current_scope -= 1
		return r
	end
end

class STMTLIST_C
	attr_accessor :stmt, :stmt_list
	def initialize(stmt, stmt_list)
		@stmt = stmt
		@stmt_list = stmt_list
	end

	def val()
		begin
			if @stmt.is_a?(RETURN_C)
				raise Interrupt
			end
		rescue Interrupt
			return @stmt.val()
		end
		r = @stmt.val()
		if @stmt_list != nil
			@stmt_list.val()
		else
			return r
		end
	end
end
