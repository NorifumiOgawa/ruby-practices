#!/usr/bin/env ruby
# frozen_string_literal: true

require 'test/unit'
require_relative 'game'

class BowlingTest < Test::Unit::TestCase
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
