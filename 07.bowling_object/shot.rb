#!/usr/bin/env ruby
# frozen_string_literal: true

class Shot
  # attr_reader :mark

  def initialize(mark)
    @mark = mark
  end

  def score
    return POINT_STRIKE if @mark == 'X'

    @mark.to_i
  end
end

# shot = Shot.new('X')
# pp shot.mark
# pp shot.score
