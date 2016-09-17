require 'rubygems'
require_relative 'FileHandler.rb'
require 'pathname'

# <font color="#062585"><font size="2">(12:11:59 PM)</font> <b>***Dan Smith</b></font> <html><span style='background: #ffffff;'>&gt; There's a strange tome to the north</span></span></html><br/>
#<font color="#062585"><font size="2">(12:11:59 PM)</font> <b>***Dan Smith</b></font> <html><span style='background: #ffffff;'>&gt; There's a strange tome to the north</span></span></html><br/>
#<font color="#16569E"><font size="2">(14:35:21)</font> <b>MrDannyDP:</b></font> <font sml="AIM/ICQ">yeah</font><br/>
		#<font color="#A82F2F"><font size="2">(14:35:25)</font> <b>Ami:</b></font> 
		#<font color="#16569E"><font size="2">(11:09:58)</font> <b>MrDannyDP:</b></font> <font sml="AIM/ICQ">totally</font><br/>
		#<font color="#A82F2F"><font size="2">(17:15:36)</font> <b>Serendipitous013:</b></font> <font sml="AIM/ICQ"><html><span style='background: #ffffff;'><em><span style='color: #800040; font-family: Monotype Corsiva; font-size: medium; '>7-up?</span></em></span></html></font><br/>
		#<font sml="AIM/ICQ"><html><span style='background: #ffffff;'>are the other ones for my viewing pleasure?</span></span></html></font>
		#<font color="A82F2F"><font size="2">(11:11:11)</font> <b>(Jon Lubbe):</b></font> <font sml="AIM/ICQ"><html><span style='background: #ffffff;'><span style='font-family: Arial; '><span style='background: #ffffff; '>perhaps you should play mr driller. =)</span></span></span></span></span></span></span></span></span></html><br/>
#<font color="#A82F2F"><font size="2">(08:06:41 PM)</font> <b>Victor:</b></font> <html><span style='background: #ffffff;'>for some reason i'm having a hard time retaining the words as i read them</span></html><br/>

#Conversation with mrdannydp at 2005-10-01 23:53:12 on MrDannyDP (aim)
class PurpleHandler <  FileHandler
	def name
		return "PurpleHandler"
	end	
        def find_content(line)
          content = ""
          line.each_char do |c|
          end
        end
	
	def process(dbh,path)
		@dbh = dbh;
		pathname = Pathname.new(path);
		filename = pathname.basename
		partner = pathname.dirname.basename
		me = pathname.dirname.dirname.basename
		if((!filename.to_s =~ /\.html$/))
			puts "Skipping #{filename}"
			return false;
		end
		#datetime = DateTime.new
		f = File.new(path)
		datetime = DateTime.new()
		protocol = ""
		pm = false;
		File.foreach(path) do|line|
			if(line =~ /Conversation\swith\s([\w.@]+)\sat\s(.+)\son\s(.+)\s\((\w+)\)/)
				partner_name = $1
				datetime = DateTime.parse($2).gregorian()
				#puts datetime.year
				me = $3
				protocol = $4
elsif line =~ /<font\scolor=\"([^>]*)\">\s*?(?:<font[^>]*>)?\(.*?\s?(\d*:\d\d:\d\d.*)\)(?:<\/font>)?\s*?<b>(.*?):?<\/b>\s*?<\/font>\s*(?:<\w+.*?>)*([^<]+)(?:<\/\w+>)*/
			#elsif(line =~ /<font\scolor=\"(.*)\">\s*?<font.*>\(.*?\s?(\d*:\d\d:\d\d.*)\)<\/font>\s*?<b>(.*):?<\/b>\s*?<\/font>\s(?:<\w+.*?>)*(.+?)(?:<\/\w+>)*<br\/>/ )		
#<font\scolor=\"([^>]*)\">\s*?(?:<font[^>]*>)?\(.*?\s?(\d*:\d\d:\d\d.*)\)(?:<\/font>)?\s*?<b>(.*?):?<\/b>\s*?<\/font>\s*(?:<\w+.*?>)*(.+?)(?:<\/\w+>)+

				time_raw = $2 #Time.parse($2)
				pm = false
				text = $4
				who = $1
				if(time_raw =~ /PM/i)
					#puts "Time is #{time_raw}"
					pm = true
				end
				if who =~ /A82F2F/ || who =~ /062585/
					to = me
					from = partner
				else
					to = partner
					from = me
				end
				#time_string = "foo"
				year = datetime.year
				month = datetime.month
				mday = datetime.mday
				
				time = DateTime.parse(time_raw).to_time
				hour = time.hour
				minute = time.min
				second = time.sec
				
				if(pm)
				 #hour += 12;
				end
				
				time_string = "#{year}-#{month}-#{mday} #{hour}:#{minute}:#{second}"
				#puts "#{time_string} #{from} to #{to}: #{$4}" 
				entry(protocol,from,to,time_string,strip_html(text))
				#<font size="2">(10:41:40)</font><b> Jon Layton logged in.</b><br/>
				#<font size="2">(14:30:58)</font><b> Jon Layton logged out.</b><br/>

			elsif (line =~ /<font*?>\(.*(\d+:\d\d:\d\d.*)\)<\/font>\s?<b>(.*?)\s(\w+\s\w+)<\/b><br\/>/)
				#<font size="2">(10:08:22)</font><b> Serendipitous013 logged in.</b><br/>
				# They did something, like, sign in
				time_raw = $1
				who = $2
				year = datetime.year
				month = datetime.month
				mday = datetime.mday
				time_string = "#{year}-#{month}-#{mday} #{time_raw}"
				what = normalize_event($3)
				if(what)
					event(protocol,who,time_string,what);
				end
			elsif (line =~ /<font.*?>\((\d+:\d\d:\d\d.*?)\)<\/font>\s?<b>.*?\[(?:<.+?>)*(.*?)(?:<\/?.+?>)*\]/) # <font size="2">(1:31:17 PM)</font><b> <span style='font-weight: bold;'>The following message received from xuqrijbuh was <em>not</em> encrypted: [</span>man.. my fucking vmware shit crashed my computer again<span style='font-weight: bold;'>]</span></b><br/>
				time_raw = $1
				text = $2
				to = me
				from = partner
				year = datetime.year
				month = datetime.month
				mday = datetime.mday
				
				time = DateTime.parse(time_raw).to_time
				hour = time.hour
				minute = time.min
				second = time.sec
				
				time_string = "#{year}-#{month}-#{mday} #{hour}:#{minute}:#{second}"
				entry(protocol,from,to,time_string,strip_html(text))
			elsif (line =~ /----\s(.*)(\w+\s\w+)\s@\s(.*)\s----/) #---- My Little Friend signed on @ 2006-04-30 01:08:02 ----<br/>  #Skip line: ---- +++ mrdanny@gmail.com/Gaim signed off @ 2006-07-29 21:25:55 ----
				who = $1
				what = normalize_event($2)
				whenn = $3 
				if(what)
					event(protocol,who,whenn,what)
				end
			else
				puts "Skip line: #{line}"
			end
		end
		
		return true
	end # process
	
	def strip_html(text)
=begin
		if(text =~ /<html.*><body.*>(.+)<\/body><\/html>/)
			return $1;
		elsif(text =~ /<html>(?:<span.*?>|<em>|\s*?)+(.+?)(?:<\/span>|<\/em>)+<\/html>/)
			return $1;
		elsif(text =~ /(?:<font.*?>\s*?)+(.+?)<\/font>/)
			return $1;
		elsif(text =~ /(?:<body.*?>\s*?)+(.+?)<\/body>/)
			return $1;
		else
			return text;
		end
=end
		return text;
	end

	def entry(protocol,from,to,date,text)
		protocol = normalize_protocol(protocol)
		record_entry(@dbh,protocol,from,to,date,text);
	end

	def event(i_protocol,who,whenn,what)
		if(what && who && whenn)
			protocol = normalize_protocol(i_protocol)
			if(valid_event_type(what))
				record_event(@dbh,protocol,who,what,whenn)
			end
		else
			puts "Event: #{who} #{whenn} #{what}"
		end
	end

	def normalize_event(what)
		if(what =~ /logged in/i)
			return "sign in";
		elsif(what =~ /logged out/i)
			return "sign out";
		elsif(what =~ /signed on/i)
			return "sign in";
		elsif(what =~ /signed off/i)
			return "sign out";
		elsif(what =~ /idle/i)
			return "idle";
		else
			return nil;
		end
	end

	def normalize_protocol(protocol)
		if(protocol =~ /Yahoo/i)
			return "Yahoo";
		elsif(protocol =~ /aim/i)
			return "AIM"
		elsif(protocol =~ /msn/i)
			return "MSN"
		elsif(protocol =~ /jabber/i)
			return "Jabber"
		end
		return protocol;
	end
end


