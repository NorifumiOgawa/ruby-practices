# frozen_string_literal: true

require 'test/unit'
require 'pathname'

class LsOopTest < Test::Unit::TestCase
  TARGET_PATHNAME = Pathname('../')
  def test_ls_a_width80
    expected = <<~TEXT.chomp
      .                 01.fizzbuzz       08.ls_object
      ..                02.calendar       09.wc_object
      .DS_Store         03.rake           README.md
      .git              04.bowling        linked.pdf
      .gitignore        05.ls             小川.txt
      .mac拡張属性      06.wc
      .rubocop.yml      07.bowling_object
    TEXT
    result = `ruby ls_oop.rb -a #{TARGET_PATHNAME}`.chomp
    assert_equal expected, result
  end

  def test_ls_l_width80
    expected = <<~TEXT.chomp
      total 8
      drwxr-xr-x  4 ogaworks  staff   128 10 30 11:18 01.fizzbuzz
      drwxr-xr-x  4 ogaworks  staff   128 10 30 11:18 02.calendar
      drwxr-xr-x  3 ogaworks  staff    96  6 10 17:17 03.rake
      drwxr-xr-x  4 ogaworks  staff   128 10 30 11:18 04.bowling
      drwxr-xr-x  3 ogaworks  staff    96 10 30 11:18 05.ls
      drwxr-xr-x  3 ogaworks  staff    96  7 11 16:19 06.wc
      drwxr-xr-x  8 ogaworks  staff   256 10 30 11:18 07.bowling_object
      drwxr-xr-x  7 ogaworks  staff   224 11 14 09:30 08.ls_object
      drwxr-xr-x  3 ogaworks  staff    96  6 10 17:17 09.wc_object
      -rw-r--r--  1 ogaworks  staff  2336  6 10 17:17 README.md
      lrwxr-xr-x  1 ogaworks  staff    39 11 13 10:05 linked.pdf -> /Users/ogaworks/desktop/event_guide.pdf
      -rw-r--r--  1 ogaworks  staff     0 11  2 18:31 小川.txt
    TEXT
    result = `ruby ls_oop.rb -l #{TARGET_PATHNAME}`.chomp
    assert_equal expected, result
  end

  def test_ls_r_width80
    expected = <<~TEXT.chomp
      小川.txt          08.ls_object      04.bowling
      linked.pdf        07.bowling_object 03.rake
      README.md         06.wc             02.calendar
      09.wc_object      05.ls             01.fizzbuzz
    TEXT
    result = `ruby ls_oop.rb -r #{TARGET_PATHNAME}`.chomp
    assert_equal expected, result
  end

  def test_ls_alr_width80
    expected = `ls -alr #{TARGET_PATHNAME}`.chomp
    result = `ruby ls_oop.rb -alr #{TARGET_PATHNAME}`.chomp
    assert_equal expected, result
  end

  def test_ls_width80
    expected = <<~TEXT.chomp
      01.fizzbuzz       05.ls             09.wc_object
      02.calendar       06.wc             README.md
      03.rake           07.bowling_object linked.pdf
      04.bowling        08.ls_object      小川.txt
    TEXT
    result = `ruby ls_oop.rb #{TARGET_PATHNAME}`.chomp
    assert_equal expected, result
  end
end
