#!/usr/bin/env ruby
# frozen_string_literal: true

require './07.bowling_object/shot'

class Frame
  def initialize(marks)
    @first_shot = Shot.new(marks[0])
    @second_shot = Shot.new(marks[1])
    @third_shot = Shot.new(marks[2])
  end

  def score
    @first_shot.score + @second_shot.score + @third_shot.score
  end
end

# frame = Frame.new('1', '9')
# pp frame.score
