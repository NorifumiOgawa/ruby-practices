# frozen_string_literal: true

require 'optparse'
require 'etc'

class Content
  PERMISSIONS = { '1' => '--x', '2' => '-w-', '3' => '-wx', '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx' }.freeze

  TYPE_LIST = {
    '001' => 'p', # FIFO
    '002' => 'c', # character device
    '004' => 'd', # directory
    '006' => 'b', # block device
    '010' => '-', # regular file
    '012' => 'l', # symbolic link
    '014' => 's' # socket
  }.freeze

  attr_reader :path, :filename

  def initialize(path, filename)
    @path = path
    @filename = filename
    @file_stat = File.lstat("#{path}#{filename}")
  end

  def blocks
    @file_stat.blocks
  end

  def nlink
    @file_stat.nlink
  end

  def user
    Etc.getpwuid(@file_stat.uid).name
  end

  def group
    Etc.getgrgid(@file_stat.gid).name
  end

  def size
    @file_stat.size
  end

  def mtime
    @file_stat.mtime
  end

  def type
    type_bit = @file_stat.mode.to_s(8).rjust(7, '0')[0, 3]
    TYPE_LIST[type_bit]
  end

  def permission
    permission_numbers = @file_stat.mode.to_s(8)[-3, 3].split('')
    permission_numbers.map { |i| PERMISSIONS[i.to_s] }.join
  end

  def filename_width
    @filename.each_char.sum { |c| c.bytesize == 1 ? 1 : 2 }
  end
end
