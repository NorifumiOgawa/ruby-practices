#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'shot'

class AllFrame
  POINT_STRIKE = 10
  def initialize(shots)
    @shots = shots
  end

  def score(frame_number)
    @frame_number = frame_number - 1
    first_shot = @shots[@frame_number][0].score
    second_shot = @shots[@frame_number][1].score
    third_shot = @shots[@frame_number][2].score

    if @frame_number == 9 # 10フレーム
      first_shot + second_shot + third_shot
    elsif first_shot == POINT_STRIKE # ストライク
      first_shot + strike_point
    elsif first_shot + second_shot == POINT_STRIKE # スペア
      first_shot + second_shot + @shots[@frame_number + 1][0].score
    else # 上記以外は2投の合計
      first_shot + second_shot + third_shot
    end
  end

  private

  def strike_point
    if @frame_number == 8
      @shots[@frame_number + 1][0].score + @shots[@frame_number + 1][1].score
    else
      strike_2nd_shot = @shots[@frame_number + 1][0].score
      strike_3rd_shot = if strike_2nd_shot == POINT_STRIKE
                          @shots[@frame_number + 2][0].score
                        else
                          @shots[@frame_number + 1][1].score
                        end
      strike_2nd_shot + strike_3rd_shot
    end
  end
end
