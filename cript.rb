require_relative "rdparse"
require_relative "cript_archetype"
##############################################################################
#
# This part defines the Cript Language
#
##############################################################################

class Cript
  def initialize
    @Cript = Parser.new("Cript") do
        """ Spaces and tabs"""
        token(/[\s\n]+/)
        token(/\t+/)

        """ Variable Typing """
        #token(/Bool/) {|m| m}
        token(/Float/) {|m| m}
        token(/\d+\.\d+/) {|m| m.to_f}
        token(/Integer/) {|m| m}
        token(/\d+/) {|m| m.to_i}

        token(/Char/) {|m| m}
        token(/String/) {|m| m}
        #token(/Array/) {|m| m}

        #token(/TRUE/) {|m| m }
        #token(/FALSE/) {|m| m }

        #token(/FOR/) {|m| :FOR }
        #token(/WHILE/) {|m| :WHILE }

        #token(/Console.Log/) {|m| m }

        #token(/Init/) {|m| :FUNCTION }

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
        token(/\w+/) {|m| m }
        token(/./){|m| m.to_s }


      """ *** Start of Statements *** """
     start :PROGRAM do
         match(:STMTLIST){|m| m.val() unless m.class == nil }
     end

      rule :STMTLIST do
          # match(:STMT, :STMTLIST){}
          match(:STMT)
      end

     rule :STMT do
            match(:ASSIGN){|m| m}
            # match(:EXPR){}
      end

      rule :ASSIGN do
         match('Integer', :VARIABLE, '=', Integer){|_, name, _, value|
             tmp = INT.new(value)
         }
         match('Float', :VARIABLE, '=', Float){|_, name, _, value|
             tmp = FLOAT.new(value)
         }
         match('Char', :VARIABLE, '=', '\'', String, '\''){|_, name, _, _, value, _|
             tmp = CHAR.new(value)
         }
         match('String', :VARIABLE, '=', '\'', String, '\''){|_, name, _, _,value,_|
             tmp = STRING.new(value)
         }
     end

       rule :EXPR do
           match(/.*/){|m| m}
       end

    #  rule :TERM do
    #      # :INT
    #       #:CHAR
    #      # :BOOL
    #       #:CLASS
    #       #:SUPER
    #       #:VARIABLE
    #   end

      rule :VARIABLE do
          match(/[a-zA-Z\-\_]+/){|m| m}
      end
      #:STMT{
    #      :FUNCTION
    #      :STD_FUNCTION
     # }

    end
  end

  def done(str)
    ["quit","exit","bye",""].include?(str.chomp)
  end

  def run
    print "[Cript++] "
    str = gets
    if done(str) then
      puts "Bye."
    else
      puts "=> #{@Cript.parse str}"
     run
    end
  end

  def log(state = true)
    if state
      @diceParser.logger.level = Logger::DEBUG
    else
      @diceParser.logger.level = Logger::WARN
    end
  end
end

# Examples of use

# irb(main):1696:0> DiceRoller.new.roll
# [diceroller] 1+3
# => 4
# [diceroller] 1+d4
# => 2
# [diceroller] 1+d4
# => 3
# [diceroller] (2+8*d20)*3d6
# => 306
