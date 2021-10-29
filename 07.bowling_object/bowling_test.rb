#!/usr/bin/env ruby
# frozen_string_literal: true

require 'test/unit'
require_relative 'game'

class BowlingTest < Test::Unit::TestCase
  def test_shot1
    assert_equal 5, Shot.new('5').score
  end

  def test_shot2
    assert_equal 0, Shot.new('0').score
  end

  def test_shot3
    assert_equal 10, Shot.new('X').score
  end

  def test_frame1
    # 1-9フレームでスペアやストライクがない場合
    marks = [%w[6 3], %w[9 0], %w[0 3], %w[8 2], %w[7 3], %w[X 0], %w[9 1], %w[8 0], %w[X 0], %w[6 4 5]]
    shots = marks.map { |mark| [Shot.new(mark[0]), Shot.new(mark[1]), Shot.new(mark[2])] }
    assert_equal 3, AllFrame.new(shots).score(3) # 3フレーム
  end

  def test_frame2
    # 10フレーム
    marks = [%w[6 3], %w[9 0], %w[0 3], %w[8 2], %w[7 3], %w[X 0], %w[9 1], %w[8 0], %w[X 0], %w[6 4 5]]
    shots = marks.map { |mark| [Shot.new(mark[0]), Shot.new(mark[1]), Shot.new(mark[2])] }
    assert_equal 15, AllFrame.new(shots).score(10) # 10フレーム
  end

  def test_frame3
    # スペアをとった場合（次の1投のスコアを加算）
    marks = [%w[6 3], %w[9 0], %w[0 3], %w[8 2], %w[7 3], %w[X 0], %w[9 1], %w[8 0], %w[X 0], %w[6 4 5]]
    shots = marks.map { |mark| [Shot.new(mark[0]), Shot.new(mark[1]), Shot.new(mark[2])] }
    assert_equal 20, AllFrame.new(shots).score(5)
  end

  def test_frame4
    # ストライクをとった場合（次の2投のスコアを加算）
    marks = [%w[6 3], %w[9 0], %w[0 3], %w[8 2], %w[7 3], %w[X 0], %w[9 1], %w[8 0], %w[X 0], %w[6 4 5]]
    shots = marks.map { |mark| [Shot.new(mark[0]), Shot.new(mark[1]), Shot.new(mark[2])] }
    assert_equal 20, AllFrame.new(shots).score(6)
  end

  def test_game1
    assert_equal 139, Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,6,4,5').score
  end

  def test_game2
    assert_equal 164, Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,X,X').score
  end

  def test_game3
    assert_equal 107, Game.new('0,10,1,5,0,0,0,0,X,X,X,5,1,8,1,0,4').score
  end

  def test_game4
    assert_equal 134, Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,0,0').score
  end

  def test_game5
    assert_equal 300, Game.new('X,X,X,X,X,X,X,X,X,X,X,X').score
  end
end
