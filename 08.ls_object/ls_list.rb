# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'content'

class LsList
  COLUMNS = 3 # 3列表示

  def initialize(path, options = nil)
    files = if options['a']
              Dir.glob('*', File::FNM_DOTMATCH, base: path)
            else
              Dir.glob('*', base: path)
            end
    files_sorted = if options['r']
                     files.reverse
                   else
                     files
                   end
    @path = path
    @options = options
    @contents = files_sorted.map { |filename| Content.new(@path, filename) }
  end

  def format_default
    file_count = @contents.size
    row = (1.0 * file_count / COLUMNS).ceil
    max_lengths = values_max_length
    listing_text = ''
    row.times do |i|
      row_text = ''
      COLUMNS.times do |j|
        break if @contents[i + j * row].nil?

        filename = @contents[i + j * row].filename
        row_text += multibyte_ljust(filename, max_lengths[:file_name] + 1) if filename
      end
      listing_text += "#{row_text.rstrip}\n"
    end
    listing_text
  end

  def format_long
    xattr_file_list = extended_attributes(@path)
    max_lengths = values_max_length
    blocks = 0
    list_texts = ''

    @contents.each do |content|
      blocks += content.blocks
      list_text = "#{content.type}#{content.permission}"
      list_text += xattr_file_list&.include?(content.filename) && content.type == '-' ? '@' : ' '
      list_text += content.nlink(@options['a'], xattr_file_list.size)
      list_text += content.user.ljust(max_lengths[:user_name])
      list_text += content.group.rjust(max_lengths[:group_name] + 2)
      list_text += content.size.to_s.rjust(max_lengths[:file_size] + 2)
      list_text += content.mtime.strftime('%-m %e %H:%M').rjust(12)
      list_text += " #{content.filename}"
      list_text += " -> #{File.readlink(@path + content.filename)}" if content.type == 'l'
      list_texts += "#{list_text}\n"
    end
    "total #{blocks}\n#{list_texts}"
  end

  def multibyte_ljust(filename, width)
    char_count = filename.each_char.sum { |c| c.bytesize == 1 ? 1 : 2 }
    filename + ' ' * (width - char_count)
  end

  private

  def values_max_length
    file_stats = @contents.map do |content|
      [content.filename.each_char.sum { |c| c.bytesize == 1 ? 1 : 2 },
       content.size.length,
       content.user.length,
       content.group.length,
       content.filename]
    end
    { file_name: file_stats.max_by { |v| v[0] }[0],
      file_size: file_stats.max_by { |v| v[1] }[1],
      user_name: file_stats.max_by { |v| v[2] }[2],
      group_name: file_stats.max_by { |v| v[3] }[3] }
  end

  def extended_attributes(path)
    # Macの拡張属性があるファイルを検索してリスト作成
    command_result = `xattr #{path}.*`
    lists = command_result.split(/\R/)
    lists.map do |list|
      list.split(':')[0].gsub(path, '')
    end.uniq
  end
end
