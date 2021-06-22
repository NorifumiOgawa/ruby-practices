#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')

# 点数をフレームに割り当てるために投球毎(shots)にする
shots = []
scores.each do |s|
  if s.casecmp('X').zero?
    shots << 10
    shots << 0 if shots.size <= 17
  else
    shots << s.to_i
  end
end

# 投球を2つ毎にまとめてフレーム(frames)にする
frames = []
shots.each_slice(2) do |s|
  frames << s
end

# もし11フレーム以降があった場合は、10フレームとマージする
while frames[10]
  frames[9] += frames[10]
  frames.delete_at(10)
end

# 得点を集計する
point = 0
frames.each_with_index do |frame, i|
  point += if i < 8 # 1~8フレーム
             if frame[0] == 10 # strike
               if frames[i + 1][0] == 10
                 10 + frames[i + 1].sum + frames[i + 2][0]
               else
                 10 + frames[i + 1].sum
               end
             elsif frame.sum == 10 # spare
               10 + frames[i + 1][0]
             else
               frame.sum
             end
           elsif i == 8 # 9フレーム
             if frame[0] == 10 # strike
               10 + frames[i + 1][0..1].sum
             elsif frame.sum == 10 # spare
               10 + frames[i + 1][0]
             else
               frame.sum
             end
           else # 10フレーム
             frame.sum
           end
end
puts point
