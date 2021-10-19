#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'shot'

class Frame
  def initialize(marks, frame_number)
    @marks = marks
    @frame_number = frame_number - 1
    @first_shot = Shot.new(@marks[@frame_number][0])
    @second_shot = Shot.new(@marks[@frame_number][1])
    @third_shot = Shot.new(@marks[@frame_number][2])
  end

  def score
    if @frame_number == 9 # 10フレーム
      @first_shot.score + @second_shot.score + @third_shot.score
    elsif @first_shot.score == 10 # ストライク
      @first_shot.score + strike_point
    elsif @first_shot.score + @second_shot.score == 10 # スペア
      @first_shot.score + @second_shot.score + Shot.new(@marks[@frame_number + 1][0]).score
    else # 上記以外は2投の合計
      @first_shot.score + @second_shot.score + @third_shot.score
    end
  end

  private

  def strike_point
    if @frame_number == 8
      Shot.new(@marks[@frame_number + 1][0]).score + Shot.new(@marks[@frame_number + 1][1]).score
    else
      strike_2nd_shot = Shot.new(@marks[@frame_number + 1][0]).score
      strike_3rd_shot = if strike_2nd_shot == 10
                          Shot.new(@marks[@frame_number + 2][0]).score
                        else
                          Shot.new(@marks[@frame_number + 1][1]).score
                        end
      strike_2nd_shot + strike_3rd_shot
    end
  end
end
