#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

COLUMNS = 3 # 3列表示
PERMISSIONS = { '1' => '--x', '2' => '-w-', '3' => '-wx', '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx' }.freeze

def main
  options = ARGV.getopts('a', 'l', 'r')
  file_list = if options['a']
                Dir.glob('*', File::FNM_DOTMATCH, base: ARGV[0])
              else
                Dir.glob('*', base: ARGV[0])
              end

  file_list.reverse! if options['r']
  if options['l']
    listing_option_l(file_list)
  else
    listing(file_list)
  end
end

def listing(file_list)
  # -l オプションなしのファイルリスト表示
  file_count = file_list.size
  row = (file_count % COLUMNS).positive? ? file_count / COLUMNS + 1 : file_count / COLUMNS
  max_lengths = values_max_length(file_list)
  listing_text = ''
  row.times do |i|
    COLUMNS.times do |ii|
      listing_text += mb_ljust(file_list[i + ii * row], max_lengths[:file_name] + 1) if i + ii * row < file_count
    end
    listing_text += "\n"
  end
  puts listing_text
end

def listing_option_l(file_list)
  # -l オプション指定時のファイルリスト表示
  # -rwxr--r--  1 ogaworks  staff   409B  6 22 22:59 ls.rb
  xattr_file_list = extended_attributes(ARGV)
  max_lengths = values_max_length(file_list)
  file_list.each do |file|
    file_path = "#{ARGV[0]}#{file}"
    stat = File.lstat(file_path)
    list_text = "#{file_type(stat.mode)}#{file_permission(stat.mode)}"
    list_text += xattr_file_list&.include?(file) && file_type(stat.mode) == '-' ? '@' : ' '
    list_text += "#{stat.nlink.to_s.rjust(3)} "
    list_text += Etc.getpwuid(File.lstat(file_path).uid).name.ljust(max_lengths[:user_name])
    list_text += Etc.getgrgid(File.lstat(file_path).gid).name.rjust(max_lengths[:group_name] + 2)
    list_text += stat.size.to_s.rjust(max_lengths[:file_size] + 2)
    list_text += stat.mtime.strftime('%-m %e %H:%M').rjust(12)
    list_text += " #{file}"
    list_text += " -> #{File.readlink(file_path)}" if file_type(stat.mode) == 'l'

    puts list_text
  end
end

def mb_ljust(file_name, width)
  char_count = file_name.each_char.sum { |c| c.bytesize == 1 ? 1 : 2 }
  file_name += ' ' * (width - char_count)
  file_name
end

def values_max_length(file_list)
  # 項目毎の最長文字数を配列で返す
  file_name_max_length = 0 # ファイル名
  file_size_max_length = 0 # ファイルサイズ
  user_name_max_length = 0 # ユーザー名
  group_name_max_length = 0 # グループ名
  file_list.each do |file|
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

def file_type(mode)
  # -l オプション) ファイルタイプを返す
  type_bit = mode.to_s(8).rjust(7, '0')[0, 3]
  {
    '001' => 'p', # FIFO
    '002' => 'c', # character device
    '004' => 'd', # directory
    '006' => 'b', # block device
    '010' => '-', # regular file
    '012' => 'l', # symbolic link
    '014' => 's' # socket
  }[type_bit]
end

def file_permission(mode)
  # -l オプション) 表示用ファイルパーミッション文字列を返す
  # ex.) -rwxr--r--
  permission_numbers = mode.to_s(8)[-3, 3].split('')
  permission_numbers.map! { |i| PERMISSIONS[i.to_s] }
  permission_numbers.join
end

def extended_attributes(argv)
  # Macの拡張属性があるファイルリスト作成
  command_result = `cd #{argv[0]} | xattr *`
  lists = command_result.split(/\R/)
  lists.map! do |list|
    list.split(':')[0]
  end
  lists.uniq!
  lists
end

main
