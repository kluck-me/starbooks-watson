# coding: utf-8
# frozen_string_literal: true
require 'natto'
require_relative 'bing_answerer'

class MecabBingAnswerer < BingAnswerer
  def self.to_words(str)
    last_word = false
    words = []
    natto = Natto::MeCab.new(dicdir: "#{`mecab-config --dicdir`.strip}/mecab-ipadic-neologd")
    natto.parse(str) do |n|
      features = n.feature.split(',')
      if features[0] == '名詞' && !%w(接尾 非自立 数 副詞可能).include?(features[1])
        word = n.surface
        if last_word
          words[-1] = "#{words[-1]}#{word}"
        else
          words << word
          last_word = true
        end
        next
      end
      last_word = false
    end
    words
  end

  def calc_score(opt)
    build_query
    query = @queries[opt]
    [self.class.bing_count(query), query]
  end

  private

  def build_query
    return if @queries
    quiz_words = self.class.to_words(quiz).uniq - opts
    unless opts.all? { |opt| opt.size < 6 }
      opt_words_set = opts.map { |opt| self.class.to_words(opt) }
      if opt_words_set.any? { |ows| ows.empty? } ||
         opt_words_set.size != opt_words_set.uniq.size ||
         opt_words_set.each_with_index.any? { |ows, i| ows.join(' ') == opts[i] } ||
         opt_words_set.any? { |ows| ows == ows & quiz_words }
        opt_words_set = nil
      end
    end
    opt_words_set ||= opts.map { |opt| [opt] }
    quiz_words -= opt_words_set.flatten
    @queries = opts.map.with_index do |opt, i|
      [opt, (quiz_words + opt_words_set[i].map { |o| "\"#{o}\"" }).join(' ')]
    end.to_h
  end
end
