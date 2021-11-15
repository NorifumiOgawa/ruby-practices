# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'content'
require 'set'

class LsFormatter
  COLUMNS = 3 # 3列表示

  def initialize(contents, xattr_files_set = nil)
    @contents = contents
    @xattr_files_set = xattr_files_set
  end

  def format(long: false)
    long ? format_long : format_default
  end

  def format_default
    file_count = @contents.size
    row = (1.0 * file_count / COLUMNS).ceil
    max_length_table = build_max_length_table
    listing_text = ''
    row.times do |i|
      row_text = ''
      COLUMNS.times do |j|
        content = @contents[i + j * row]
        break if content.nil?

        row_text += content.filename + ' ' * ((max_length_table[:filename] + 1) - content.filename_width)
      end
      listing_text += "#{row_text.rstrip}\n"
    end
    listing_text
  end

  def format_long
    max_length_table = build_max_length_table
    blocks = 0

    list_texts = @contents.map do |content|
      blocks += content.blocks
      list_text = "#{content.type}#{content.permission}"
      list_text += @xattr_files_set&.include?(content.filename) && content.type == '-' ? '@' : ' '
      list_text += "#{content.nlink.to_s.rjust(max_length_table[:nlink] + 1)} "
      list_text += content.user.ljust(max_length_table[:username])
      list_text += content.group.rjust(max_length_table[:groupname] + 2)
      list_text += content.size.to_s.rjust(max_length_table[:filesize] + 2)
      list_text += content.mtime.strftime('%-m %e %H:%M').rjust(12)
      list_text += " #{content.filename}"
      list_text += " -> #{File.readlink(content.path + content.filename)}" if content.type == 'l'
      list_text
    end
    "total #{blocks}\n#{list_texts.join("\n")}"
  end

  private

  def build_max_length_table
    {
      filename: @contents.map(&:filename_width).max,
      filesize: @contents.map { |content| content.size.to_s.length }.max,
      username: @contents.map { |content| content.user.length }.max,
      groupname: @contents.map { |content| content.group.length }.max,
      nlink: @contents.map { |content| content.nlink.to_s.length }.max
    }
  end
end
