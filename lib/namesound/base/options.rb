# frozen_string_literal: true

require_relative "failure"
require_relative "text"

module Namesound
  module Options
    Parsed = Struct.new(:flags, :settings, :args)

    def self.parse(argv, flags, valued)
      parsed_flags = Set.new
      settings = {}
      args = []
      index = 0

      while index < argv.length
        argument = argv[index]
        if argument.start_with?("--")
          equals_index = argument.index("=")
          name = equals_index ? argument[0...equals_index] : argument

          if valued.include?(name)
            if equals_index
              settings[name] = argument[(equals_index + 1)..]
            else
              index += 1
              raise Failure, "#{name} needs a value" if index >= argv.length

              settings[name] = argv[index]
            end
          elsif flags.include?(argument)
            parsed_flags.add(argument)
          else
            raise Failure, "unknown option #{Text.show(argument)}"
          end
        else
          args << argument
        end
        index += 1
      end

      Parsed.new(parsed_flags, settings, args)
    end
  end
end
