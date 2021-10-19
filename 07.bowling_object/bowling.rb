#!/usr/bin/env ruby
# frozen_string_literal: true

require './07.bowling_object/game'

game = Game.new(ARGV[0])
puts game.score
