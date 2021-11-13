# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'content'
require 'set'

class LsList
  COLUMNS = 3 # 3列表示

  def initialize(path, options = nil)
    files = options['a'] ? Dir.glob('*', File::FNM_DOTMATCH, base: path) : Dir.glob('*', base: path)
    sorted_files = options['r'] ? files.reverse : files
    @path = path
    @options = options
    @contents = sorted_files.map { |filename| Content.new(@path, filename) }
  end

  def format_default
    file_count = @contents.size
    row = (1.0 * file_count / COLUMNS).ceil
    max_lengths = values_max_length
    listing_text = ''
    row.times do |i|
      row_text = ''
      COLUMNS.times do |j|
        content = @contents[i + j * row]
        break if content.nil?

        row_text += content.filename + ' ' * ((max_lengths[:file_name] + 1) - content.filename_length)
      end
      listing_text += "#{row_text.rstrip}\n"
    end
    listing_text
  end

  def format_long
    xattr_file_list = extended_attributes(@path)
    max_lengths = values_max_length
    blocks = 0

    list_texts = @contents.map do |content|
      blocks += content.blocks
      list_text = "#{content.type}#{content.permission}"
      list_text += xattr_file_list&.include?(content.filename) && content.type == '-' ? '@' : ' '
      list_text += nlink_rjust(content, xattr_file_list)
      list_text += content.user.ljust(max_lengths[:user_name])
      list_text += content.group.rjust(max_lengths[:group_name] + 2)
      list_text += content.size.to_s.rjust(max_lengths[:file_size] + 2)
      list_text += content.mtime.strftime('%-m %e %H:%M').rjust(12)
      list_text += " #{content.filename}"
      list_text += " -> #{File.readlink(@path + content.filename)}" if content.type == 'l'
      list_text
    end
    "total #{blocks}\n#{list_texts.join("\n")}"
  end

  private

  def nlink_rjust(content, xattr_file_list)
    if @options['a'] && xattr_file_list.size.positive?
      "#{content.nlink.to_s.rjust(3)} "
    else
      "#{content.nlink.to_s.rjust(2)} "
    end
  end

  def values_max_length
    file_stats = @contents.map do |content|
      { file_name: content.filename_length,
        file_size: content.size.to_s.length,
        user_name: content.user.length,
        group_name: content.group.length }
    end
    { file_name: file_stats.max_by { |file_stat| file_stat[:file_name] }[:file_name],
      file_size: file_stats.max_by { |file_stat| file_stat[:file_size] }[:file_size],
      user_name: file_stats.max_by { |file_stat| file_stat[:user_name] }[:user_name],
      group_name: file_stats.max_by { |file_stat| file_stat[:group_name] }[:group_name] }
  end

  def extended_attributes(path)
    # Macの拡張属性があるファイルを検索してリスト作成
    command_result = `xattr #{path}.*`
    lists = command_result.split(/\R/)
    file_names = lists.map do |list|
      list.split(':')[0].gsub(path, '')
    end.uniq
    Set[*file_names]
  end
end
