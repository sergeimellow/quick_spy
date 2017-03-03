require 'nokogiri'
require 'restclient'
require 'uri'
require './spider'

# TODO: For some reason after a few minutes the requests start to all fail.
# Figure that out.
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
