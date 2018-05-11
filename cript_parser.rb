#!/usr/bin/env ruby
require_relative "rdparse"
require_relative "cript_classes"

##############################################################################
#
# This part defines the Cript Language
#
##############################################################################

class Cript
	def initialize
		@Cript = Parser.new("Cript") do
			#""" *** Spaces and tabs *** """

			token(/[\s]+/)
			token(/\t+/)

			token(/\/\/.*\n/)

			rule :BOOL_STMT do
				match(:TERM, :OPERATOR, :BOOL_STMT){|a, op, b| Object.const_get(op + "_C").new(a, b)}
				match(:TERM, :OPERATOR, :EXPR){|a, op, b| Object.const_get(op+ "_C").new(a, b)}
				match(:TERM){|m| m }
			end

			#""" *** Separators *** """

			token(/^\;/) { |m| m }

			#""" *** Variable Typing *** """

			token(/Bool/) { |m| m }

			token(/True/) { |m| m }
			token(/False/) { |m| m }

			token(/Float/) { |m| m }
			token(/\d+\.\d+/) { |m| m.to_f }

			token(/Integer/) { |m| m }
			token(/\d+/) { |m| m.to_i }

			token(/Char/) { |m| m }



			#""" *** Container Typing *** """

			token(/String/) { |m| m }
			token(/Array/) { |m| m }

			#""" *** Keywords *** """
			token(/Init/) { |m| m }
			token(/If/) { |m| m }
			token(/Else/){ |m| m }
			token(/Not/) { |m| m }
			token(/And/) { |m| m }
			token(/Or/) { |m| m }
			token(/==/) { |m| m }
			token(/Return/){ |m| m }
			token(/While/) { |m| m }
			token(/Print/) { |m| m }


			#token(/For/) {|m| :FOR }



			#""" *** Operators *** """

			#token(/>>/){|m|m}
			#token(/!=/) {|m| m }
			#token(/>/) {|m| m }
			#token(/>=/) {|m| m }
			#token(/</) {|m| m }
			#token(/<=/) {|m| m }
			token(/\w+/) { |m| m }
			token(/["'][a-zA-Z\_\,\. 0-9]+["']/) { |m| m }
			token(/./) { |m| m.to_s }

			#""" *** Start of Statements *** """
			start :PROGRAM do
				match(:STMTLIST) { |m| m.val() unless m.class == nil }
			end

			rule :STMTLIST do
				match(:STMT, :STMTLIST) { |s, sl| STMTLIST_C.new(s,sl) }
				match(:STMT) { |s| STMTLIST_C.new(s,nil) }
			end

			rule :STMT do
				match(:IFSTMT) { |m| m }
				match(:LOOPSTMT){ |m| m }
				match(/Return/, :EXPR, /;?/) { |_, m, _| RETURN_C.new(m) }
				match(:ASSIGN) { |m| m }
				match(:EXPR, /;?/) { |m, _| m }

			end

			rule :VARIABLE_NAME do
				match(/[a-zA-Z]+[a-zA-Z\-\_0-9]*/) { |m| m }
			end


			rule :ASSIGN do
				match(/Init/, :VARIABLE_NAME, /\(/, :PARAM_LIST, /\)/, /{/, :STMTLIST, /}/) {|_, name, _, params, _, _, stmt_list, _|
					ASSIGN_FUNC.new(name, params, stmt_list)
				}
				match(/Init/, :VARIABLE_NAME, /\(/, /\)/, /{/, :STMTLIST, /}/) {|_, name, _, _, _, stmt_list, _|
					ASSIGN_FUNC.new(name, nil, stmt_list)
				}
				match(:VARIABLE_TYPE, :VARIABLE_NAME, "=", :EXPR, ";") { |type, name, _, value, _|
					ASSIGN_VAR.new(type + "_C", name, value)
				}
				match(:VARIABLE_NAME, "=", :EXPR, ";") { |name, _, value, _|
					RE_VAR.new(name, value)
				}
			end



			rule :IFSTMT do
				match(/If/, /\(/, :BOOL_STMT, /\)/, /{/, :STMTLIST, /}/, /Else/, /{/, :STMTLIST, /}/){
					|_, _, bool_stmt, _, _, stmt_list1, _, _, _, stmt_list2, _|
						IF_C.new(bool_stmt, stmt_list1, stmt_list2)
					}
				match(/If/, /\(/, :BOOL_STMT, /\)/, /{/, :STMTLIST, /}/){
					 |_, _, bool_stmt, _, _, stmt_list, _|
					 IF_C.new(bool_stmt, stmt_list, nil)
					}

			end

			rule :BOOL_STMT do
				match(:TERM, :OPERATOR, :BOOL_STMT){|a, op, b| Object.const_get(op + "_C").new(a, b)}
				match(:TERM, :OPERATOR, :EXPR){|a, op, b| Object.const_get(op+ "_C").new(a, b)}
				match(:TERM){|m| m }
			end

			rule :LOOPSTMT do
				match(/While/, "(", :BOOL_STMT, ")", "{", :STMTLIST, "}") { |_, _, cond, _, _, stmt, _| WHILE_C.new(stmt, cond) }
			end

			rule :OPERATOR do
				match(/And/){ |_| "AND" }
				match(/Or/) { |_| "OR" }
				match(/==/) { |_| "EQUALS" }
			end

			rule :EXPR do
				match(:EXPR, "+", :TERM) { |a, _, b, _| ADD.new(a, b) }
				match(:EXPR, "-", :TERM) { |a, _, b, _| SUBTRACT.new(a, b) }
				match(:BOOL_STMT){ |m| m}

				match(:TERM)
			end

			rule :TERM do
				match("True") { |_| BOOL_C.new(true) }
				match("False") { |_| BOOL_C.new(false) }
				match(/Not/, :EXPR) { |_ ,b| BOOL_C.new(!b.val()) }

				match(:TERM, "*", :EXPR) { |a, _, b| MULTIPLY.new(a, b) }
				match(:TERM, "/", :EXPR) { |a, _, b| DIVIDE.new(a, b) }
				match(Integer) { |m| INTEGER_C.new(m) }
				match(Float) { |m| FLOAT_C.new(m) }

				match(:STR) { |m| m }
				match(/Print/, /\(/, :EXPR, /\)/) { |_, _, m, _| PRINT_C.new(m) }
				match(:FUNC_CALL) {|m| m}
				match(:VARIABLE_NAME) { |m| LOOKUP_VAR.new(m) }
			end

			rule :VARIABLE_TYPE do
				match(/Bool/) { |m| m.upcase }
				match(/Integer/) { |m| m.upcase }
				match(/Float/) { |m| m.upcase }
				match(/Char/) { |m| m.upcase }
				match(/String/) { |m| m.upcase }
			end

			rule :STR do
				match(/["'][a-zA-Z\_\,\. 0-9]+["']/) { |m| STRING_C.new(m[1..-2]) }
				match(/["']/, /["']/) { STRING_C.new("") }
			end

			rule :FUNC_CALL do
				match(:VARIABLE_NAME, /\(/, :ARGUMENT_LIST, /\)/) { |name, _, params, _| LOOKUP_FUNC.new(name, params) }
				match(:VARIABLE_NAME, /\(/, /\)/) { |name, _, _, _| LOOKUP_FUNC.new(name, nil) }
			end

			rule :PARAM_LIST do
				match(:VARIABLE_TYPE, :VARIABLE_NAME, ',', :PARAM_LIST){ |type, name, _, n| [n]<<[name, type] }
				match(:VARIABLE_TYPE, :VARIABLE_NAME){ |type, name| [name, type] }
				match(""){nil}
			end

			rule :ARGUMENT_LIST do
				match(:EXPR, ',', :ARGUMENT_LIST){ |m, _, n| [n] << m }
				match(:EXPR){ |m| m }
				match(""){nil}
	  		end
		end
	end

	def parser(str = "")
		if str.length == 0
			print "[Cript++]~ "
			str = gets
			while !done(str)
				@Cript.parse str
				print "[Cript++]~ "
				str = gets
			end
		else
			@Cript.parse str
			return
		end
	end

	def done(str)
		["quit;", "exit;", "bye;", ""].include?(str.chomp)
	end

	def log(state = false)
		if state
			@Cript.logger.level = Logger::DEBUG
		else
			@Cript.logger.level = Logger::WARN
		end
	end
end




if __FILE__ == $0
	DEBUG = false
	parser = Cript.new
	parser.log(DEBUG)
	if ARGV.empty?
		parser.parser()
	else
		f = ARGV[0]
		file = File.open(f, "r")
		parser.parser(file.read)
	end
end
