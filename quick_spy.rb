require 'nokogiri'
require 'restclient'
require 'uri'
require './spider'
class QuickSpy
  def initialize
    @affected_counter = 0
    @spider = Spider.new(self)
  end
  # TODO: Move parser functionality here
  def start
    @spider.start_spider
  end
end
