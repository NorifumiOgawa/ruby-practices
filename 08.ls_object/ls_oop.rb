# frozen_string_literal: true

require_relative 'ls_list'

class LsOop
  def initialize
    @options = ARGV.getopts('a', 'l', 'r')
    @ls_list = LsList.new(ARGV[0], @options)
  end

  def self.listing_result
    new.listing_result
  end

  def listing_result
    if @options['l']
      puts @ls_list.format_long
    else
      puts @ls_list.format_default
    end
  end
end

LsOop.listing_result if __FILE__ == $PROGRAM_NAME
