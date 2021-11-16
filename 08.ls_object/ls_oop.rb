# frozen_string_literal: true

require_relative 'content'
require_relative 'ls_formatter'
require 'optparse'
require 'set'

class LsOop
  def initialize
    @options = ARGV.getopts('a', 'l', 'r')
    @path = ARGV[0]
  end

  def self.display_list
    new.display_list
  end

  def display_list
    files = @options['a'] ? Dir.glob('*', File::FNM_DOTMATCH, base: @path) : Dir.glob('*', base: @path)
    sorted_files = @options['r'] ? files.reverse : files
    contents = sorted_files.map { |filename| Content.new(@path, filename) }
    @ls_formatter = LsFormatter.new(contents, build_xattr_files_set(@path))
    puts @ls_formatter.format(long: @options['l'])
  end

  def build_xattr_files_set(path)
    # Macの拡張属性があるファイルを検索してSetオブジェクトを返す
    command_result = `xattr #{path}* #{path}.*`
    lists = command_result.split(/\R/)
    filename = lists.map do |list|
      list.split(':')[0].gsub(path, '')
    end.uniq
    Set[*filename]
  end
end

LsOop.display_list if __FILE__ == $PROGRAM_NAME
