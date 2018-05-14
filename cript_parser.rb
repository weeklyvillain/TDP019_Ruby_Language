#!/usr/bin/env ruby
require_relative "rdparse"
require_relative "cript_classes"

##############################################################################
#
#						 Parser for the Cript++ Language
#
# 		Based on RDPARSE and built by Jimbj685 and Filer358 in 05/2018
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
			token(/Run/) { |m| m }
			token(/Wait/) { |m| m }
			token(/Randi/) { |m| m }
			token(/Randf/) { |m| m }

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
				match(/Not/, :EXPR) { |_ ,b| NOT_C.new(b) }
				match(:TERM, "*", :EXPR) { |a, _, b| MULTIPLY.new(a, b) }
				match(:TERM, "/", :EXPR) { |a, _, b| DIVIDE.new(a, b) }
				match(:ARRAY) { |m| m}
				match(:STR) { |m| m }
				match(:INT) { |m| m }
				match(:FLOAT) { |m| m }
				match(/Print/, /\(/, :EXPR, /\)/) { |_, _, m, _| PRINT_C.new(m) }
				match(/Run/, /\(/, :STR, /\)/) { |_, _ , m, _| RUN_C.new(m)}
				match(/Randi/, /\(/, :INT, /\,/ , :INT,  /\)/){ |_, _, start, _, stop,  _| RAND_INT.new(start, stop) }
				match(/Randf/, /\(/, :FLOAT, /\,/ , :FLOAT,  /\)/){ |_, _, start, _, stop, _| RAND_FLOAT.new(start, stop) }
				match(/Wait/, /\(/, :INT, /\)/) { |_, _, m, _| WAIT_C.new(m) }
				match(/Wait/, /\(/, :FLOAT, /\)/) { |_, _, m, _| WAIT_C.new(m) }
				match(/Return/, :EXPR) { |_, m| RETURN_C.new(m) }
				match(:FUNC_CALL) {|m| m}
				match(:VARIABLE_NAME) { |m| LOOKUP_VAR.new(m) }
			end

			rule :VARIABLE_TYPE do
				match(/Bool/) { |m| m.upcase }
				match(/Integer/) { |m| m.upcase }
				match(/Float/) { |m| m.upcase }
				match(/Char/) { |m| m.upcase }
				match(/String/) { |m| m.upcase }
				match(/Array/) { |m| m.upcase }
			end
			rule :ARRAY do
				match(:VARIABLE_NAME, /\[/, :INT, /\]/, /\=/, :TERM) { |name, _, index, _ , _ , new_value| RE_ARRAY_C.new(name, index, new_value) }
				match(:VARIABLE_NAME, /\[/, :INT, /\]/) { |name, _, index, _| GET_ARRAY_C.new(name, index).value }
				match(/Array/, /</, :VARIABLE_TYPE, />/, :VARIABLE_NAME, /\=/, /\[/, :ARRAY_LIST, /\]/) { |_, _, type, _, name, _, _, array_list, _ | ASSIGN_VAR.new("ARRAY_C", name, ARRAY_C.new(array_list.reverse, type))}
			end

			rule :STR do
				match(/["'][a-zA-Z\_\,\. 0-9]+["']/) { |m| STRING_C.new(m[1..-2]) }
				match(/["']/, /["']/) { STRING_C.new("") }
			end

			rule :INT do
				match(Integer) { |m| INTEGER_C.new(m) }
			end

			rule :FLOAT do
				match(Float) { |m| FLOAT_C.new(m) }
			end

			rule :FUNC_CALL do
				match(:VARIABLE_NAME, /\(/, :ARGUMENT_LIST, /\)/) { |name, _, params, _|
					LOOKUP_FUNC.new(name, params) }
				match(:VARIABLE_NAME, /\(/, /\)/) { |name, _, _, _| LOOKUP_FUNC.new(name, nil) }
			end

			rule :PARAM_LIST do
				match(:VARIABLE_TYPE, :VARIABLE_NAME, ',', :PARAM_LIST){ |type, name, _, n|
					if n.is_a? Array
						n.push([name, type])
					else
						[] << [[name, type]]
					end
				 }
				match(:VARIABLE_TYPE, :VARIABLE_NAME){ |type, name| [] << [name, type] }
				match(""){nil}
			end

			rule :ARRAY_LIST do
				match(:TERM, ',', :ARRAY_LIST) { |m, _, n|
					if n.is_a? Array
						n << m
					else
				 		[n] << m
					end
				}
				match(:TERM){ |m| [] << m }
			end

			rule :ARGUMENT_LIST do
				match(:TERM, ',', :ARGUMENT_LIST){ |m, _, n|
					if n.is_a? Array
						n << m
					else
					 	[n] << m
					end
				}
				match(:TERM){ |m| [] << m }
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
			return @Cript.parse str
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
