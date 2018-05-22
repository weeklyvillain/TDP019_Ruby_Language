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
		if value.class == Fixnum
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
		if value.class == Float
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
		if value.class == String
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
		if value == true or value == false
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
		$all_variables.push({})
		$functions.push({})
		$current_scope += 1
		if params != nil && @params != nil
			(-1..@params.length - 1).each { |i|
				$all_variables[$current_scope].store(@params[i][0], params[i])
			}
		end
		begin
			r = @block.val()
			$all_variables.pop()
			$functions.pop()
			$current_scope -= 1
			return r
		rescue ReturnException => e
			return e.object.val()
		end
	end
end

class STMTLIST_C
	attr_accessor :stmt, :stmt_list
	def initialize(stmt, stmt_list)
		@stmt = stmt
		@stmt_list = stmt_list
	end

	def val()
		r = @stmt.val()
		if @stmt_list != nil
			return @stmt_list.val()
		else
			return r
		end
	end
end
