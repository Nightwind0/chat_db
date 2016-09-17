require_relative 'PurpleHandler.rb'

#<FONT COLOR="#ff0000"><B>00:14:34 rAsBeRRy DiVa:</B></FONT> <HTML><BODY BGCOLOR="#ffffff"><FONT>ok, I dont know who sabrina, and did you say your poems?</FONT></BODY></HTML>
#><H3 Align=Center> ---- New Conversation @ 21:49:46 ----</H3><BR>
#<HR><BR><H3 Align=Center> ---- New Conversation @ Mon May  8 18:55:55 2000 ----</H3><BR>
#<FONT COLOR="#0000ff"><B>22:26:37 MrDannyDP:</B></FONT> (it was especially effective on girls in skirts btw)
#<FONT COLOR="#ff0000"><B>22:26:59 BruceLee18:</B></FONT> <HTML><BODY BGCOLOR="#ffffff"><FONT>HOLY SHIT!!!!</FONT></BODY></HTML>
#/<font\scolor=\"(.*)\">\s*?<font.*>\(.*?\s?(\d*:\d\d:\d\d.*)\)<\/font>\s*?<b>(.*):?<\/b>\s*?<\/font>\s(?:<\w+.*?>)*(.+?)(?:<\/\w+>)*<br\/>/
#<FONT\sCOLOR=\"#(.*?)\">.*?\(?(\d*:\d\d:\d\d)\)?\s(?:<BR>)?(.+?):.*?<\/FONT>(?:<\w+.*?>)*(.+)(?:<\/\w+>)*
# <FONT COLOR="#ff0000"><FONT SIZE="2">(10:39:51) </FONT><B>amIbuG84:</B></FONT> <HTML><BODY GCOLOR="#ffffff"><FONT COLOR="#000080" FACE="LongIsland">*tries to wake mrdannydp up</FONT></BODY></HTML><BR>


class GaimHandler < PurpleHandler
  def name
    return "GaimHandler";
  end
	def process(dbh,path)
		@default_date = "01/01/1970"
		@dbh = dbh;
		@me = @arguments[2]
		pathname = Pathname.new(path);
		filename = pathname.basename
		if((filename.to_s =~ /(.*).log$/))
			partner_name = $1
			puts "Partner: #{partner_name}"
			#datetime = DateTime.new
			f = File.new(path)
			datetime = DateTime.parse(@default_date)
			protocol = ""
			pm = false;
			File.foreach(path) do|line|
				# ----\sNew\sConversation\s\@\s(\w+?)\s(\w+?)\s*(\d+)\s(\d*:\d\d:\d\d)\s(\d+)\s----
				if(line =~ /----\sNew\sConversation\s\@\s(\w+?)\s(\w+?)\s*(\d+)\s(\d*:\d\d:\d\d)\s(\d+)\s----/)
					date_part = $2+' '+$3+',' +$5				
                                        puts "Date: #{date_part}"
					datetime = DateTime.parse(date_part).gregorian
				elsif(line =~ /<FONT\sCOLOR=\"#(.*?)\">.*?\(?(\d*:\d\d:\d\d)\)?\s(?:<BR>)?(.+?):.*?<\/FONT>(.+)/ )		
					time_raw = $2 #Time.parse($2)
					pm = false
					text = $4
					who = $3
					color= $1
					if(time_raw =~ /PM/i)
						#puts "Time is #{time_raw}"
						pm = true
					end
					if(color.eql?("ff0000"))
						to = @me
						from = who
					else
						to = partner_name
						from = @me
					end
					#time_string = "foo"
					year = datetime.year
					month = datetime.month
					mday = datetime.mday
				
					time = DateTime.parse(time_raw).to_time
					hour = time.hour
					minute = time.min
					second = time.sec
				
					time_string = "#{year}-#{month}-#{mday} #{hour}:#{minute}:#{second}"
					#puts "#{time_string} #{from} to #{to}: #{$4}" 
					entry(protocol,from,to,time_string,strip_html(text))
					#<font size="2">(10:41:40)</font><b> Jon Layton logged in.</b><br/>
					#<font size="2">(14:30:58)</font><b> Jon Layton logged out.</b><br/>
					#<HR><B>TheBiggerDragon logged out @ 03:01:03.</B><BR><HR><BR>
				elsif (line =~ /(?:<.*>\s*)*(\w+?)\s(\w+?\s\w+?)\s@\s(\d*:\d\d:\d\d)\./)
					time_raw = $3
					who = $1
					what = normalize_event($2)
					year = datetime.year
					month = datetime.month
					mday = datetime.mday
					time_string = "#{year}-#{month}-#{mday} #{hour}:#{minute}:#{second}"
					if(what)
						event(protocol,who,time_string,what)
					end
				#(20:08:36) MrDannyDP: because of the cheese and the tigers<BR>
				elsif (line =~ /\(?(\d*:\d\d:\d\d)\)?\s(.*):\s(.*)/)
					time_raw = $1
					who = $2
					what = $3
					if(!who.eql?(@me))
						to = @me
						from = who
					else
						to = partner_name
						from = @me
					end
					#time_string = "foo"
					year = datetime.year
					month = datetime.month
					mday = datetime.mday
				
					time = DateTime.parse(time_raw).to_time
					hour = time.hour
					minute = time.min
					second = time.sec
				
					time_string = "#{year}-#{month}-#{mday} #{hour}:#{minute}:#{second}"
					entry(protocol,from,to,time_string,what)
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
		
		else
			puts "Skipping file #{filename}"
			return false;
		end
		
		return true
	end # process
	
	def strip_html (text)
		if(text =~ /(?:<.*?>\s*)+(.*?)(?:<\/\w+?>\s*)+?/)
			return $1;
		else
			return text;
		end
	end
end
