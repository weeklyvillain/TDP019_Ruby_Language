require_relative "ruler.rb"

if __FILE__ == $0
    context = build_context("example_code.rlr")
    context.actions["say"] = lambda do |text|
        puts(text)
    end

    counter = 0
    context.actions["increment"] = lambda do |count|
        counter += count
        puts "Counter increased by #{count} to #{counter}."
    end

    context.facts["self_type"] = Obj.to_rlr("player")
    context.facts["self_hp"] = Obj.to_rlr(0)
    context.facts["self_race"] = Obj.to_rlr("human")
    context.facts["player_seen_elf"] = Obj.to_rlr(false)
    context.execute
end
