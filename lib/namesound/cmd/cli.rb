# frozen_string_literal: true

require_relative "../base/failure"
require_relative "../base/inputs"
require_relative "../base/options"
require_relative "../base/text"
require_relative "algorithms_command"
require_relative "key_command"
require_relative "group_command"
require_relative "compare_command"

module Namesound
  module Cli
    def self.run(argv, io)
      raise Failure, "missing command (algorithms, key, group or compare)" if argv.empty?
      if argv.any? { |argument| !argument.dup.force_encoding(Encoding::UTF_8).valid_encoding? }
        raise Failure, "argument is not valid UTF-8"
      end

      if argv == ["--help"]
        io.out("usage: namesound algorithms\n       namesound key [--bare] ALGORITHM FILE\n       " \
               "namesound group [--min N] ALGORITHM FILE...\n       " \
               "namesound compare [--algorithm NAME] NAME1 NAME2\n")
        return 0
      end

      command = argv[0]
      arguments = argv.drop(1)
      inputs = Inputs.new(io)
      output = case command
               when "algorithms"
                 parsed = Options.parse(arguments, Set.new, Set.new)
                 AlgorithmsCommand.run(parsed.args, parsed.flags, parsed.settings, inputs)
               when "key"
                 parsed = Options.parse(arguments, Set.new(["--bare"]), Set.new)
                 KeyCommand.run(parsed.args, parsed.flags, parsed.settings, inputs)
               when "group"
                 parsed = Options.parse(arguments, Set.new, Set.new(["--min"]))
                 GroupCommand.run(parsed.args, parsed.flags, parsed.settings, inputs)
               when "compare"
                 parsed = Options.parse(arguments, Set.new, Set.new(["--algorithm"]))
                 CompareCommand.run(parsed.args, parsed.flags, parsed.settings, inputs)
               else
                 raise Failure, "unknown command #{Text.show(command)}"
               end

      io.out(output.out) unless output.out.empty?
      output.code
    rescue Failure => e
      io.err("namesound: #{e.message}\n")
      2
    end
  end
end
