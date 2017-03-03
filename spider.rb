require 'typhoeus'
require 'concurrent'

# Current this is configured to quickly timeout requests on sites.
# This increases the successful requests per minute but also really increases
# the number of failures. Increasing the time out or decreasing the
# number of simultaneous requests per Tyhpoeus hydra should help.
# Need to find the sweet spot based on your hardware/connection.
class Spider
  def initialize(quick_spy)
    @site_queue = ['www.reddit.com']
    @parse_list = Concurrent::Array.new
    @init_time = Time.now
    @quick_spy = quick_spy
    @hosts_list = []
    @success_count = 0
    @affected_counter = 0
    @failure_count = 0
  end

  def start_spider
    scraper = Thread.new{ start_scraping }
    parser = Thread.new{ start_parsing }
    scraper.join
    parser.join
  end

  def start_parsing
    loop do
      if @parse_list.any?
        parse_response(@parse_list.pop)
      else
        sleep 1
      end
    end
  end

  def start_scraping
    # while @site_queue.any?
    loop do
      hydra = Typhoeus::Hydra.new
      pop_sites.each_with_index do |site, index|
        request = Typhoeus::Request.new(site, followlocation: true, timeout: 8)
        request.on_complete do |response|
          if response.success?
            # puts "Success: #{site}."
            @parse_list << response
            @success_count += 1
          else
            # puts "Failure: #{site}."
            @failure_count += 1
          end
        end
        hydra.queue(request)
      end
      hydra.run
      report
      sleep 5
    end
  end

  private

  def report
    puts '******* BEGIN REPORT *******'
    puts " Elapsed Time: #{(Time.now - @init_time).round} seconds"
    puts " Success Count: #{@success_count}"
    puts " Failure Count: #{@failure_count}"
    puts "Detected Count: #{@affected_counter}"
    puts "           RPM: #{calculate_rpm}"
    puts "   Queue Count: #{@site_queue.count}"
    puts "   Parse Count: #{@parse_list.count}"
    puts '*******  END REPORT  *******'
  end

  def pop_sites
    @site_queue.slice!(0, 80)
  end

  def parse_response(response)
    begin
      Nokogiri::HTML(response.body).css('a').each do |link|
        if check_href(link)
          @site_queue.push(link.attributes['href'].value)
          @hosts_list << get_host_without_www(link.attributes['href'].value)
        end
      end
    rescue => e
      puts "Exception during parsing: #{e}"
    end
  end

  def parse_anchors(anchors)
    anchors.each do |link|
      if check_href(link)
        url = link.attributes['href'].value
        test_for_cloudflare(url)
        @site_queue.push(url)
        @hosts_list << get_host_without_www(url)
      end
    end
  end

  def check_href(link)
    link&.attributes['href']&.value =~ /\A#{URI::regexp(['http', 'https'])}\z/ && !@hosts_list.include?(get_host_without_www(link.attributes['href'].value))
  end

  # URL always gets parsed twice
  def get_host_without_www(url)
    url = "http://#{url}" if URI.parse(url).scheme.nil?
    host = URI.parse(url).host.downcase
    host.start_with?('www.') ? host[4..-1] : host
  end

  def calculate_rpm
    elapsed_minutes = (Time.now - @init_time) / 60
    (@success_count / elapsed_minutes).round
  end

  def test_for_cloudflare(url)
    # puts "Checking #{get_host_without_www(url)}..."
    if !`dig #{get_host_without_www(url)} ns | grep cloudflare`.empty?
      puts "#{get_host_without_www(url)} potentially affected by cloudbleed."
      @affected_counter += 1
    end
  end
end
