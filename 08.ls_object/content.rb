# frozen_string_literal: true

require 'optparse'
require 'etc'

class Content
  PERMISSIONS = { '1' => '--x', '2' => '-w-', '3' => '-wx', '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx' }.freeze

  def initialize(path)
    @file = File.lstat("#{ARGV[0]}#{path}")
  end

  def blocks
    @file.blocks
  end

  def nlink(option_a, xattr_file_list)
    if option_a && xattr_file_list.size.positive?
      "#{@file.nlink.to_s.rjust(3)} "
    else
      "#{@file.nlink.to_s.rjust(2)} "
    end
  end

  def type
    # -l オプション) ファイルタイプを返す
    type_bit = @file.mode.to_s(8).rjust(7, '0')[0, 3]
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

  def permission
    # -l オプション) 表示用ファイルパーミッション文字列を返す
    # ex.) -rwxr--r--
    permission_numbers = @file.mode.to_s(8)[-3, 3].split('')
    permission_numbers.map! { |i| PERMISSIONS[i.to_s] }.join
  end
end
