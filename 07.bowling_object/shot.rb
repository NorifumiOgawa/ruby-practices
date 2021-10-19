#!/usr/bin/env ruby
# frozen_string_literal: true

POINT_STRIKE = 10

class Shot
  def initialize(mark)
    @mark = mark
  end

  def score
    return POINT_STRIKE if @mark == 'X'

    @mark.to_i
  end
end
