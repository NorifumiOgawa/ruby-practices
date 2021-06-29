#!/usr/bin/env ruby
# frozen_string_literal: true

# in: $ wc filename
# out: {行数} {単語数} {バイト数} {ファイル名}

require 'optparse'

@result_line_count = []
@result_word_count = []
@result_byte = []
@result_filename = []
@options = ARGV.getopts('l')

def main
  input_params
  input_stdin if @result_filename.size.zero?

  @result_line_count.size.times do |i|
    print @result_line_count[i].to_s.rjust(8)
    print "#{@result_word_count[i].to_s.rjust(8)}#{@result_byte[i].to_s.rjust(8)}" unless @options['l']
    puts " #{@result_filename[i]}"
  end
  return unless ARGV.size.positive?

  print @result_line_count.sum.to_s.rjust(8)
  print "#{@result_word_count.sum.to_s.rjust(8)}#{@result_byte.sum.to_s.rjust(8)}" unless @options['l']
  puts ' total'
end

# 引数によるファイル名入力
def input_params
  file_list = ARGV if ARGV.size.positive?
  file_list&.each { |file| aggregate_files(file) }
end

# 標準入力からの文字列入力
def input_stdin
  lines = $stdin.read
  @result_line_count[0] = lines.count("\n")
  @result_word_count[0] = lines.split(/\p{blank}+|\s+/).count { |el| !el.empty? }
  @result_byte[0] = lines.bytesize
end

# ファイル毎に内容を取得
def aggregate_files(file)
  file_content = File.open(file).read
  @result_line_count << file_content.count("\n")
  @result_word_count << file_content.split(/\p{blank}+|\s+/).count { |el| !el.empty? }
  @result_byte << File::Stat.new(file).size
  @result_filename << file
end

main
