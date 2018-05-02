"""********** INTEGER **********"""
class INTEGER_C
	attr_accessor :value, :type
	def initialize(value)
		@value = value
		@type = :INT
	end
	def to_s()
		self.val()
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

""" *** FUNCTIONS *** """

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
#		if params != nil
			# (0..@params.length).each{ |i| 
			# 	begin 
			# 		if params[i].respond_to?(:val)
			# 			params[i] = params[i].val
					
			# 		@@all_variables[@@current_scope][@params[i]['name']] = Object.const_get(@params[i]['type']).new(params[i]) 
			# 	rescue
			# 		if @params[i].is_a? DefaultParam do
			# 			# assigna värdet från defa
			# 		else
			# 			reraise
			# 		end
			# 	end
			
		r = @block.val()
		@@all_variables.pop()
		@@current_scope -= 1
		r
	end
end
