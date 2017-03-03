require 'nokogiri'
require 'restclient'
require 'typhoeus'
site_queue = [
'http://www.yahoo.com/',
'http://www.google.com/',
'http://www.youtube.com/',
'http://www.live.com/',
'http://www.facebook.com/',
'http://www.msn.com/',
'http://www.myspace.com/',
'http://www.wikipedia.org/',
'http://www.blogger.com/',
'http://www.yahoo.co.jp/',
'http://www.baidu.com/',
'http://www.rapidshare.com/',
'http://www.microsoft.com/',
'http://www.google.co.in/',
'http://www.google.de/',
'http://www.hi5.com/',
'http://www.qq.com/',
'http://www.ebay.com/',
'http://www.google.fr/',
'http://www.sina.com.cn/',
'http://www.google.co.uk/',
'http://www.mail.ru/',
'http://www.orkut.com.br/',
'http://www.fc2.com/',
'http://www.aol.com/',
'http://www.vkontakte.ru/',
'http://www.google.com.br/',
'http://www.wordpress.com/',
'http://www.google.it/',
'http://www.flickr.com/',
'http://www.photobucket.com/',
'http://www.yandex.ru/',
'http://www.google.es/',
'http://www.google.co.jp/',
'http://www.google.cn/',
'http://www.amazon.com/',
'http://www.go.com/',
'http://www.naver.com/',
'http://www.craigslist.org/',
'http://www.friendster.com/',
'http://www.odnoklassniki.ru/',
'http://www.orkut.co.in/',
'http://www.google.com.mx/',
'http://www.imdb.com/',
'http://www.bbc.co.uk/',
'http://www.youporn.com/',
'http://www.taobao.com/',
'http://www.cnn.com/',
'http://www.adultfriendfinder.com/',
'http://www.googlesyndication.com/',
'http://www.skyrock.com/',
'http://www.163.com/',
'http://www.redtube.com/',
'http://www.imageshack.us/',
'http://www.youku.com/',
'http://www.ask.com/',
'http://www.google.ca/',
'http://www.uol.com.br/',
'http://www.pornhub.com/',
'http://www.espn.go.com/',
'http://www.adobe.com/',
'http://www.rakuten.co.jp/',
'http://www.orkut.com/',
'http://www.sohu.com/',
'http://www.ebay.de/',
'http://www.netlog.com/',
'http://www.apple.com/',
'http://www.dailymotion.com/',
'http://www.mixi.jp/',
'http://www.metroflog.com/',
'http://www.rambler.ru/',
'http://www.daum.net/',
'http://www.vmn.net/',
'http://www.rediff.com/',
'http://www.livedoor.com/',
'http://www.yahoo.com.cn/',
'http://www.google.com.tr/',
'http://www.fastclick.com/',
'http://www.fotolog.net/',
'http://www.livejournal.com/',
'http://www.about.com/',
'http://www.megavideo.com/',
'http://www.nytimes.com/',
'http://www.globo.com/',
'http://www.nicovideo.jp/',
'http://www.wretch.cc/',
'http://www.mininova.org/',
'http://www.soso.com/',
'http://www.google.com.au/',
'http://www.ameblo.jp/',
'http://www.nasza-klasa.pl/',
'http://www.google.pl/',
'http://www.goo.ne.jp/',
'http://www.google.co.id/',
'http://www.google.com.sa/',
'http://www.ku6.com/',
'http://www.yourfilehost.com/',
'http://www.imagevenue.com/',
'http://www.bebo.com/',
'http://www.comcast.net',
'http://www.google.ru/',
'http://ebay.co.uk/',
'http://www.free.fr/',
'http://www.mediafire.com/',
'http://www.4shared.com/',
'http://www.terra.com.br/',
'http://www.veoh.com/',
'http://www.megaupload.com/',
'http://www.xunlei.com/',
'http://www.google.nl/',
'http://www.xvideos.com/',
'http://www.perfspot.com/',
'http://www.google.co.th/',
'http://www.google.com.ar/',
'http://www.zshare.net/',
'http://www.weather.com/',
'http://www.deviantart.com/',
'http://www.tube8.com/',
'http://www.geocities.com/',
'http://www.doubleclick.com/',
'http://www.download.com/',
'http://www.orange.fr/',
'http://www.nifty.com/',
'http://www.amazon.co.jp/',
'http://www.tagged.com/',
'http://www.livejasmin.com/',
'http://www.sogou.com/',
'http://www.thepiratebay.org/',
'http://www.mop.com/',
'http://www.2ch.net/',
'http://www.gmx.net/',
'http://www.metacafe.com/',
'http://www.clicksor.com/',
'http://www.tudou.com/',
'http://www.adultadworld.com/',
'http://www.pconline.com.cn/',
'http://www.homeway.com.cn/',
'http://www.clicksor.net/',
'http://www.partypoker.com/',
'http://www.biglobe.ne.jp/',
'http://www.xnxx.com/',
'http://www.cyworld.com/',
'http://www.amazon.de/',
'http://www.maktoob.com/',
'http://www.geocities.jp/',
'http://www.google.co.za/',
'http://www.tribalfusion.com/',
'http://www.studiverzeichnis.com/',
'http://www.infoseek.co.jp/',
'http://www.sourceforge.net/',
'http://www.dell.com/',
'http://www.alibaba.com/',
'http://www.google.com.eg/',
'http://www.onet.pl/',
'http://www.cnet.com/',
'http://www.zol.com.cn/',
'http://www.kaixin00.com/',
'http://www.conduit.com/',
'http://www.gamespot.com/',
'http://www.imeem.com/',
'http://www.tinypic.com/',
'http://www.icq.com/',
'http://www.reference.com/',
'http://www.sakura.ne.jp/',
'http://www.alice.it/',
'http://www.ig.com.br/',
'http://www.answers.com/',
'http://www.multiply.com/',
'http://www.libero.it/',
'http://www.aim.com/',
'http://www.hyves.nl/',
'http://www.files.wordpress.com/',
'http://www.google.co.ve/',
'http://www.depositfiles.com/',
'http://www.ign.com/',
'http://www.wikimedia.org/',
'http://www.blogfa.com/',
'http://www.narod.ru/',
'http://www.mapquest.com/',
'http://www.xiaonei.com/',
'http://www.web.de/',
'http://www.hp.com/',
'http://www.google.com.co/',
'http://www.sonico.com/',
'http://www.smileycentral.com/',
'http://www.google.com.pk/',
'http://www.easy-share.com/',
'http://www.google.be/',
'http://www.vnexpress.net/',
'http://www.brazzers.com/',
'http://www.linkedin.com/',
'http://www.allegro.pl/',
'http://www.mozilla.com/',
'http://www.seznam.cz/',
'http://www.bp.blogspot.com/',
'http://www.pogo.com/',
'http://www.people.com.cn/',
'http://www.zedo.com/',
'http://www.miniclip.com/',
'http://www.filefactory.com/']

# timer = Time.now
# threads = []
# site_queue.each do |site|
#   threads << Thread.new {
#     begin
#       RestClient.get(site)
#     rescue => e
#       puts "Site timeout"
#     end
#   }
# end
# threads.each{|x| x.join}
# puts "Threads took: #{Time.now - timer}"

#
hydra = Typhoeus::Hydra.new
timer = Time.now
success_count = 0
fail_count = 0
puts "Count: #{site_queue.count}"
site_queue.each_with_index do |site, index|
  request = Typhoeus::Request.new(site, followlocation: true, timeout: 5)
  request.on_complete do |response|
    puts "Site Done: #{site}. Success: #{response.success?}"
    begin
      puts Nokogiri::HTML(response.body).css('a')
    rescue

    end
    response.success? ? success_count += 1 : fail_count += 1
  end
  hydra.queue(request)
  if (index % 100) == 0
    puts "Index: #{index}"
    hydra.run
  end
end
hydra.run
puts "Typhoeus took: #{Time.now - timer}"
puts "Success Count: #{success_count}"
puts "Fail Count: #{fail_count}"




# Typhoeus took: 19.701178 with 50
