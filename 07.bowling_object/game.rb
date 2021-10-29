#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'all_frame'
require_relative 'shot'

class Game
  def initialize(result_marks)
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
    shots = @marks.map { |mark| [Shot.new(mark[0]), Shot.new(mark[1]), Shot.new(mark[2])] }
    shots.each.with_index(1) do |_shot, i|
      score += AllFrame.new(shots).score(i)
    end
    score
  end
end
