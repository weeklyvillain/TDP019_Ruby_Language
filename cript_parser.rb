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
			""" *** Spaces and tabs *** """

			token(/[\s\n]+/)
			token(/\t+/)

			""" *** Separators *** """

			token(/^\;/) { |m| m }

			""" *** Variable Typing *** """

			token(/Bool/) { |m| m }

			token(/True/) { |m| m }
			token(/False/) { |m| m }

			token(/Float/) { |m| m }
			token(/\d+\.\d+/) { |m| m.to_f }

			token(/Integer/) { |m| m }
			token(/\d+/) { |m| m.to_i }

			token(/Char/) { |m| m }

			""" *** Container Typing *** """

			token(/String/) { |m| m }
			token(/Array/) { |m| m }

			""" *** Keywords *** """

			token(/If/) { |m| m }
			#token(/For/) {|m| :FOR }
			#token(/While/) {|m| :WHILE }

			#token(/Console.Log/) {|m| m }

			token(/Init/) { |m| m }

			#token(/>>/){|m|m}
			#token(/==/) {|m| m }
			#token(/!=/) {|m| m }
			#token(/>/) {|m| m }
			#token(/>=/) {|m| m }
			#token(/</) {|m| m }
			#token(/<=/) {|m| m }
			#token(/&&/) {|m| m }
			#token(/||/) {|m| m }
			#token(/!/) {|m| m }
			token(/\w+/) { |m| m }
			token(/["'][a-zA-Z\_\,\. ]+["']/) { |m| m }
			token(/./) { |m| m.to_s }

			""" *** Start of Statements *** """
			start :PROGRAM do
				match(:STMTLIST) { |m| m.val() unless m.class == nil }
			end

			rule :STMTLIST do
				match(:STMT, :STMTLIST)
				match(:STMT)
			end

			rule :STMT do
				match(:FUNCDEF){ |m| m }
				match(:ASSIGN) { |m| m }

				match(:EXPR, /;?/) { |m, _| m }

			end

			rule :ASSIGN do
				match(:VARIABLE_TYPE, :VARIABLE_NAME, "=", :EXPR, ";") { |type, name, _, value, _|
					ASSIGN_VAR.new(type + "_C", name, value, 0)
				}
			end

			rule :EXPR do
				match(:EXPR, "+", :TERM) { |a, _, b, _| ADD.new(a, b) }
				match(:EXPR, "-", :TERM) { |a, _, b, _| SUBTRACT.new(a, b) }
				match(:TERM)


			end

			rule :TERM do
				match("True") { true }
				match("False") { false }
				match(:TERM, "*", :TERM) { |a, _, b| MULTIPLY.new(a, b) }
				match(:TERM, "/", :TERM) { |a, _, b| DIVIDE.new(a, b) }
				match(Integer) { |m| m }
				match(Float) { |m| m }
				match(:STR) { |m| m }

				match(:FUNC_CALL) {|m| m}
				match(:VARIABLE_NAME) { |m| LOOKUP_VAR.new(m, 0) }



			end

			rule :VARIABLE_TYPE do
				match(/Bool/) { |m| m.upcase }
				match(/Integer/) { |m| m.upcase }
				match(/Float/) { |m| m.upcase }
				match(/Char/) { |m| m.upcase }
				match(/String/) { |m| m.upcase }
			end

			rule :VARIABLE_NAME do
				match(/[a-zA-Z]+[a-zA-Z\-\_0-9]*/) { |m| m }
			end

			rule :STR do
				match(/["'][a-zA-Z\_\,\. ]+["']/) { |m| m[1..-2] }
				match(/["']/, /["']/) { "" }
			end

			rule :PARAM_LIST do

				match(:VARIABLE_TYPE, :VARIABLE_NAME, ',', :PARAM_LIST){ |type, name, _, n| [n]<<[name, type] }
				match(:VARIABLE_TYPE, :VARIABLE_NAME){ |type, name| [name, type] }
				match(""){nil}
			end
			
			rule :ARGUMENT_LIST do
				match(:EXPR, ',', :ARGUMENT_LIST){ |m, _, n| [n]<<[m] }
				match(:EXPR){ |m| [m] }
				match(""){nil}
	  		end


			rule :FUNCDEF do
				match(/Init/, :VARIABLE_NAME, /\(/, :PARAM_LIST, /\)/, /{/, :STMTLIST, /}/) {|_, name, _, params, _, _, stmt_list, _|
					ASSIGN_FUNC.new(name, params, stmt_list)
				}
				match(/Init/, :VARIABLE_NAME, /\(/, /\)/, /{/, :STMTLIST, /}/) {|_, name, _, _, _, stmt_list, _|
					ASSIGN_FUNC.new(name, nil, stmt_list)
				}
				
				#match(:INIT, :VARIABLE_NAME, /\(/, /[a-zA-Z]+/, /\)/, /\{/, :EXPR, /\};/){
				#	|_, name, _, params, _, _, stmt_list, _|
				#	FUNCTION_C.new(name, params.split(','), stmt_list)
				#}
			end

			rule :FUNC_CALL do
				match(:VARIABLE_NAME, /\(/, :ARGUMENT_LIST, /\)/) { |name, _, params, _| LOOKUP_FUNC.new(name, 0, params) }
				match(:VARIABLE_NAME, /\(/, /\)/) { |name, _, _, _| LOOKUP_FUNC.new(name, 0, nil) }
			end
		end
	end

	def done(str)
		["quit", "exit", "bye", ""].include?(str.chomp)
	end

	def parser(str = "")
		print_variable_table()
		#print_func_table()
		print "[Cript++]~ "
		if str.length == 0
			str = gets
		else
			if done(str)
				puts "Bye."
			else
				puts "=> #{@Cript.parse str}"
				return
			end
		end

		if done(str)
			puts "Bye."
		else
			puts "=> #{@Cript.parse str}"
			parser
		end
	end

	def log(state = false)
		if state
			@Cript.logger.level = Logger::DEBUG
		else
			@Cript.logger.level = Logger::WARN
		end
	end

	def print_variable_table(state = true)
		if state
			ALL_VARIABLES.each_with_index { |scope_variables, scope|
				puts "\nScope: " + scope.to_s
				for x in 0..scope_variables.length - 1
					print "\nVariable Name: " + scope_variables.keys[x].to_s + " {"
					print "\n   Value: " + scope_variables[scope_variables.keys[x]].val.to_s + ","
					print "\n   Datatype: " + scope_variables[scope_variables.keys[x]].type.to_s + "\n}\n\n"
				end
			}
		end
	end

	def print_func_table(state = true)
		if state
			FUNCTIONS.each_with_index { |scope_funs, scope|
				puts "\nScope: " + scope.to_s
				for x in 0..scope_funs.length - 1
					print "\nFunction Name: " + scope_funs.keys[x].to_s + " {"
					print "\n   Block: " + scope_funs[scope_funs.keys[x]].val.to_s + ","
					print "\n	Params: " + scope_funs[scope_funs.keys[x]].params.to_s + "\n}\n\n"
				end
			}
		end
	end
end



if __FILE__ == $0
	debug = true
	if ARGV.empty?
		c = Cript.new
		c.log(debug)
		c.parser()
	else
		f = ARGV[0]
		file = File.open(f, "r")
		parser = Cript.new
		parser.log(debug)
		for line in file
			parser.parser(line)
		end
	end
end
