# frozen_string_literal: true
require_relative 'answerer'

class BingAnswerer < Answerer
  def self.new_agent
    Mechanize.new { |agent| agent.user_agent_alias = 'Mac Firefox' }
  end

  def self.bing_count(q)
    count_node = new_agent.get('http://www.bing.com/search?' + URI.encode_www_form(q: q)).at('.sb_count')
    count_node ? count_node.text.match(/^[\d,]+/)[0].gsub(/,/, '').to_i : 0
  end

  def calc_score(opt)
    self.class.bing_count("#{quiz} #{opt}")
  end
end
