# frozen_string_literal: true
require 'mechanize'
require 'textpants'

class Answerer
  attr_reader :quiz, :opts

  def self.choose_answer(data)
    data.map.with_index.max_by { |d, _| d[:score] }.last
  end

  def initialize(quiz)
    @quiz = Textpants.squish(quiz)
  end

  def think(*args)
    think_(*args) do |opt|
      result = calc_score(opt)
      if result.is_a?(Array)
        {
          opt: opt,
          args: result[1..-1],
          score: result.first
        }
      else
        {
          opt: opt,
          score: result
        }
      end
    end
  end

  private

  def think_(*opts)
    Enumerator.new do |y|
      @opts = opts.map { |opt| Textpants.squish(opt) }
      @opts.each do |*args|
        y << yield(*args)
      end
    end
  end
end
