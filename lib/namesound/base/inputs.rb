# frozen_string_literal: true

require_relative "failure"
require_relative "text"

module Namesound
  class Inputs
    Source = Struct.new(:label, :text)

    def initialize(io)
      @io = io
      @stdin_read = false
    end

    def read(arg)
      label = arg == "-" ? "<stdin>" : Text.plain(arg)
      bytes = read_bytes(arg, label)
      Source.new(label, decode(bytes, label))
    end

    def self.entries(text)
      entries = []
      text.split("\n", -1).each do |line|
        line = line.delete_suffix("\r")
        line = line.sub(/\A[ \t]+/, "").sub(/[ \t]+\z/, "")
        entries << line unless line.empty?
      end
      entries
    end

    private

    def read_bytes(arg, label)
      if arg == "-"
        raise Failure, "standard input is named twice" if @stdin_read

        @stdin_read = true
        @io.read_stdin
      else
        @io.read_file(arg)
      end
    rescue IOError
      raise Failure, "#{label}: cannot read the file"
    end

    def decode(bytes, label)
      text = bytes.dup.force_encoding(Encoding::UTF_8)
      raise Failure, "#{label}: input is not valid UTF-8" unless text.valid_encoding?

      text
    end
  end
end
