require 'typhoeus'
require 'concurrent'

class Spider

  def initialize(quick_spy)
    @site_queue = ['www.reddit.com']
    @parse_list = Concurrent::Array.new
    @init_time = Time.now
    @quick_spy = quick_spy
    @hosts_list = []
    @success_count = 0
    @failure_count = 0
  end

  def start_spider
    scraper = Thread.new{ start_scraping }
    parser = Thread.new{ start_parsing }
    scraper.join
    parser.join
    # loop do
    #   # well
    # end
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
            # puts "Site success: #{site}."
            @parse_list << response
            # parse_response(response)
            @success_count += 1
          else
            # puts "Site failure: #{site}."
            @failure_count += 1
          end
        end
        hydra.queue(request)
      end
      hydra.run
      report
      # puts "Checking #{get_host_without_www(url)}..."
      # if !`dig #{get_host_without_www(url)} ns | grep cloudflare`.empty?
        # puts "#{get_host_without_www(url)} potentially affected by cloudbleed."
      #   @affected_counter += 1
      # end
    end
  end

  private

  def report
    puts '******* BEGIN REPORT *******'
    puts " Elapsed Time: #{(Time.now - @init_time).round} seconds"
    puts "Success Count: #{@success_count}"
    puts "Failure Count: #{@failure_count}"
    puts "          RPM: #{calculate_rpm}"
    puts "  Queue Count: #{@site_queue.count}"
    puts "  Parse Count: #{@parse_list.count}"
    puts '*******  END REPORT  *******'
  end

  def pop_sites
    @site_queue.slice!(0, 100)
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
        @site_queue.push(link.attributes['href'].value)
        @hosts_list << get_host_without_www(link.attributes['href'].value)
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
end
