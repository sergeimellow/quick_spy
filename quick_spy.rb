require 'nokogiri'
require 'restclient'
require 'uri'
require './spider'

class QuickSpy
  def initialize
    @affected_counter = 0
    @spider = Spider.new(self)
  end

  def start
    @spider.start_spider
  end
end

# QuickSpy holds spider, spider will handle threaded requests and parsing of
# the responses
