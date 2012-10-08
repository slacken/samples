#! /usr/bin/ruby
#encoding: utf-8
require 'mysql'
require 'uri'
require 'open-uri'

BEGIN{
  beigin_time = Time.now
  #puts "Begin at #{beigin_time}"
}
END{
  end_time = Time.now.to_time
  puts "Finished, and it takes #{end_time-beigin_time} seconds"
}


class Crawler

  @@db = {:host=>"localhost",:user=>"root",:password=>"111111",:database=>"twenty"}

  def initialize(site)
    @site = site # site id
    @connect = Mysql.new(@@db[:host],@@db[:user],@@db[:password],@@db[:database])
    @connect.query("SET NAMES utf8")
    # make cache dir
    Dir.mkdir("cache") if(!File.exist?('cache'))
    # make the site subdir
    Dir.mkdir(@site) if(!File.exist?(@site))
  end

  # config the crawler
  def config

  end


  def fetch_urls_witd_sitemap(sitemap,url_like)
    urls = []
  end

  def fetch_urls_with_archieve(archieve,min,max,url_like)
    urls = []
    count = max - min
    min.upto(max){ |i|
      Thread.new{
        url = archieve.clone # reference value
        url["{num}"] = i.to_s
        f = open(url)
        content = f.read
        f.close
        content.gsub(url_like){|u| urls.push(full_url(u,url)) }
        count -= 1
        print "."
      }
    }
    while count >= 0
      # wait
    end
    urls.uniq!
    to_file("#{@site}_index",urls)
  end


  def begin
  end

  # save the post to database
  def save(post)

    post['keywords'] = post['keywords'].join(",")
    
  end

  # exit
  def stop
    @connect.close
    exit!
  end


  # private method are dedined here
  private


  # insert hash value into table
  def insert(table,row)
    sql = "INSERT INTO `#{@@db[:database]}`.`#{table}` "
    keys = ""
    values = ""
    row.each_pair{|k,v|
      keys <<= "`#{k}`,"
      values <<= "'#{v}'," # escape the string 
    }
    keys = "("+keys[0...-1]+") VALUES "
    values = "("+values[0...-1]+")"

    sql = sql + keys + values

    @connect.query(sql)
  end

  def to_file(file,value)
    str = Marshal.dump(value)
    # f = File.open("cache/#{file}","w")
    # f.write(str)
    # f.close
    File.write("cache/#{file}",str)
  end

  def from_file(file)
    return nil if !File.readable?("cache/#{file}")
    str = File.read("cache/#{file}")
    Marshal.load(str)
  end

  # full url of href value in a page with current_url
  def full_url(url,current_url)
    uri = URI.parse(current_url)

    base = uri.scheme+"://"+uri.host

    return url if (url.start_with?("http") || url.start_with?(uri.scheme))
    return base+url if url.start_with?("/")

    # the URI lib's path seems not fits well
    path = uri.path[/\S*\//]
    base+path+url

  end

end

c = Crawler.new("ucdchina")

c.fetch_urls_with_archieve("http://ucdchina.com/category/all?p={num}",0,2,%r|/snap/[\d]{1,5}|)

c.stop



__END__

