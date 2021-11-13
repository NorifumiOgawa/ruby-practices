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
  attr_reader :filename

  def initialize(path, filename)
    @path = path
    @filename = filename
    @file = File.lstat("#{path}#{filename}")
  end

  def blocks
    @file.blocks
  end

  def nlink
    @file.nlink
  end

  def user
    Etc.getpwuid(@file.uid).name
  end

  def group
    Etc.getgrgid(@file.gid).name
  end

  def size
    @file.size
  end

  def mtime
    @file.mtime
  end

  def type
    type_bit = @file.mode.to_s(8).rjust(7, '0')[0, 3]
    TYPE_LIST[type_bit]
  end

  def permission
    permission_numbers = @file.mode.to_s(8)[-3, 3].split('')
    permission_numbers.map { |i| PERMISSIONS[i.to_s] }.join
  end

  def filename_length
    @filename.each_char.sum { |c| c.bytesize == 1 ? 1 : 2 }
  end
end
