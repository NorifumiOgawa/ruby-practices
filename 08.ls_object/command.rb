# frozen_string_literal: true

require_relative 'list'

class Command
  def initialize
    @options = ARGV.getopts('a', 'l', 'r')
    @list = List.new(ARGV[0], @options)
  end

  def listing_result
    if @options['l']
      puts @list.format_long
    else
      puts @list.format_default
    end
  end
end
