module NilIfInitializationFails
  def self.new_if_valid(*args)
    self.new(*args)
  rescue InitializationInvalidError
    nil
  end
end
class InitializationInvalidError < StandardError; end