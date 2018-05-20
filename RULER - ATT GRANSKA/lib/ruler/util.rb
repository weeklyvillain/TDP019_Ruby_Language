module Assertions
    def self.not_nil(value)
        if value.nil?
            raise ArgumentError, "Expected non-nil value."
        end
        return value
    end

    def self.check(condition)
        unless condition
            raise ArgumentError, "Expected condition to equal true."
        end
    end

    def self.check_type(token, type)
        unless token.type == type
            raise ArgumentError, "Expected #{type} but got #{token.type}."
        end
    end

    def self.is_obj(value, type)
        unless value.instance_of?(Obj) && value.type == type
            raise ArgumentError, "Expected an object of type #{type}."
        end
        return value
    end
end
