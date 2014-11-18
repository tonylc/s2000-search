require 'rubygems'
require 'open-uri'
require 'nokogiri'

DEBUG_ON = true

def debug_print(msg)
  if DEBUG_ON
    p "******** #{msg}"
  end
end

CRAIGSLIST_SUBDOMAIN = %w(bakersfield chico fresno goldcountry hanford humboldt imperial inlandempire losangeles
 mendocino merced modesto monterey orangecounty palmsprings redding sacramento sandiego sfbay slo santabarbara
 santamaria siskiyou stockton susanville ventura visalia yubasutter)

CRAIGSLIST_SUBDOMAIN = %w(bakersfield chico fresno goldcountry)

out_file = File.new("#{Time.now.strftime("%Y-%m-%d")}-s2000.html", "w")

CRAIGSLIST_SUBDOMAIN.each do |subdomain|
  debug_print("processing #{subdomain}")
  out_file.puts("<p>********#{subdomain.upcase}********")
  sleep(1)
  s2k_found = false
  page = Nokogiri::HTML(open("http://#{subdomain}.craigslist.org/search/cta?query=s2000"))
  page.css("article#pagecontainer div.rightpane div.content").children.each_with_index do |p,i|
    if p.text =~ /^\s*$/
      debug_print("white space, skip")
      if s2k_found
        break
      else
        next
      end
    end
    if p.text =~ /Few LOCAL results found. Here are some from NEARBY areas/
      || p.text =~ /Zero LOCAL results found. Here are some from NEARBY areas/
      debug_print("End of local results: break")
      break
    end
    if p.text =~ /s2000/i
      s2k_found = true
      p.css("span.txt a.hdrlnk").each do |anchor_link|
        anchor_link['href'] = "http://#{subdomain}.craigslist.org" + anchor_link['href']
        puts "#{i}: #{anchor_link.text}"
      end
      # trim cruft
      p.search('a .price').each do |n|
        n.parent.remove
        n.remove
      end
      p.search('.gc,.maptag').each {|n| n.remove}
      out_file.puts(p)
    end
  end
end

out_file.close
