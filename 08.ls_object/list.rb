# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'content'

class List
  COLUMNS = 3 # 3列表示

  def initialize(path, options = nil)
    @dir_glob = if options['a']
                  Dir.glob('*', File::FNM_DOTMATCH, base: path)
                else
                  Dir.glob('*', base: path)
                end
    @options = options
    @dir_glob.reverse! if options['r']
    @contents = []
    build_contents
  end

  def format_default
    # -l オプションなしのファイルリスト表示
    file_count = @contents.size
    row = (file_count % COLUMNS).positive? ? file_count / COLUMNS + 1 : file_count / COLUMNS
    max_lengths = values_max_length
    listing_text = ''
    row.times do |i|
      COLUMNS.times do |ii|
        listing_text += mb_ljust(@dir_glob[i + ii * row], max_lengths[:file_name] + 1) if i + ii * row < file_count
      end
      listing_text.rstrip!
      listing_text += "\n"
    end
    listing_text
  end

  def format_long
    # -l オプション指定時のファイルリスト表示
    # -rwxr--r--  1 ogaworks  staff   409B  6 22 22:59 ls.rb
    xattr_file_list = extended_attributes(ARGV)
    max_lengths = values_max_length
    blocks = 0
    list_texts = ''
    @dir_glob.each_with_index do |file, i|
      blocks += @contents[i].blocks
      file_path = "#{ARGV[0]}#{file}"
      stat = File.lstat(file_path)
      list_text = "#{@contents[i].type}#{@contents[i].permission}"
      list_text += xattr_file_list&.include?(file) && @contents[i].type == '-' ? '@' : ' '
      list_text += @contents[i].nlink(@options['a'], xattr_file_list.size)
      list_text += Etc.getpwuid(File.lstat(file_path).uid).name.ljust(max_lengths[:user_name])
      list_text += Etc.getgrgid(File.lstat(file_path).gid).name.rjust(max_lengths[:group_name] + 2)
      list_text += stat.size.to_s.rjust(max_lengths[:file_size] + 2)
      list_text += stat.mtime.strftime('%-m %e %H:%M').rjust(12)
      list_text += " #{file}"
      list_text += " -> #{File.readlink(file_path)}" if @contents[i].type == 'l'
      list_texts += "#{list_text}\n"
    end
    "total #{blocks}\n#{list_texts}"
  end

  def mb_ljust(file_name, width)
    char_count = file_name.each_char.sum { |c| c.bytesize == 1 ? 1 : 2 }
    file_name += ' ' * (width - char_count)
    file_name
  end

  def values_max_length
    # 項目毎の最長文字数を配列で返す
    file_name_max_length = 0 # ファイル名
    file_size_max_length = 0 # ファイルサイズ
    user_name_max_length = 0 # ユーザー名
    group_name_max_length = 0 # グループ名
    @dir_glob.each do |file|
      file_path = "#{ARGV[0]}#{file}"
      stat = File.lstat(file_path)
      file_name_length = file.each_char.sum { |c| c.bytesize == 1 ? 1 : 2 }
      file_name_max_length = file_name_length if file_name_max_length < file_name_length
      file_size_max_length = stat.size if file_size_max_length < stat.size
      user_name_max_length = Etc.getpwuid(File.lstat(file_path).uid).name.length if user_name_max_length < Etc.getpwuid(File.lstat(file_path).uid).name.length
      group_name_max_length = Etc.getgrgid(File.lstat(file_path).gid).name.length if group_name_max_length < Etc.getgrgid(File.lstat(file_path).gid).name.length
    end
    { file_name: file_name_max_length, file_size: file_size_max_length.to_s.size, user_name: user_name_max_length, group_name: group_name_max_length }
  end

  private

  def build_contents
    # ここで、指定パス以下の対象物をContent.newする
    @dir_glob.each do |content|
      @contents << Content.new(content)
    end
  end

  def extended_attributes(argv)
    # Macの拡張属性があるファイルリスト作成
    command_result = `xattr #{argv[0]}.*`
    lists = command_result.split(/\R/)
    lists.map! do |list|
      list.split(':')[0].gsub!(argv[0], '')
    end
    lists.uniq!
    lists
  end
end
