#!/usr/bin/env ruby
# frozen_string_literal: true

require './07.bowling_object/frame'

class Game
  def initialize
    result_marks = ARGV[0]

    # マークを配列にする
    marks_array = []
    result_marks.split(',').each do |m|
      marks_array << m
      marks_array << '0' if m == 'X' && marks_array.size <= 17
    end

    # マークをフレームごとの配列にする
    @marks = marks_array.each_slice(2).to_a
    return unless @marks[10]

    # もし11フレームがあった場合は、10フレームとマージする
    @marks[9] += @marks[10]
    @marks.delete_at(10)
  end

  def score
    score = 0
    @marks.each do |mark|
      frame = Frame.new(mark)
      score += frame.score
    end
    score
  end
end
