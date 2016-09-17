require 'rubygems'
require_relative 'FileHandler.rb'
require 'xmlsimple'
require 'pathname'

class Adium2Handler <  FileHandler
	
	def name
		return "Adium2Handler"
	end

	def process(dbh,path)
		@dbh = dbh;
		pathname = Pathname.new(path);
		filename = pathname.basename
		if(filename.to_s =~ /^[^.].*\.xml$/)
			partner = pathname.dirname.dirname.basename
		elsif (filename.to_s =~ /\.chatlog$/)
			partner = pathname.dirname.basename
		else
			puts "Skipping '#{filename}'"
			return false
		end

		
		#partner = dir_components.basename # filename not that interesting
		puts "Partner: #{partner}"
		#partner = dir_components.basename # the directory this is in tells us who we are talking to

		xml = XmlSimple.xml_in(path,{ 'ForceArray' => true });
		me = xml["account"]

		protocol = xml["service"]
		entries = xml["message"];
		events = xml["event"];
		if(entries.kind_of?(Array))
			entries.each do |entry|
				from = entry["sender"]

				if(from.eql? me)
					to = partner;
				else
					to = me;
				end

				date = entry["time"]
				divs = entry["div"]
				divs.each do |div|
					if(div["span"])
						span = div["span"]
						if(span.kind_of?(Array))
							fulltext = ""
							span.each do |eachspan|
								content = eachspan["content"];
								if(content.kind_of?(Array))
									content.each do |eachcontent|
										fulltext += eachcontent;
									end
								else
									if(content)
										fulltext += content;
									end
								end
							end
							entry(protocol,from,to,date,fulltext)
						else
							text = span["content"]
							entry(from,to,date,text)
						end
					else
						if(div["a"])
							links = div["a"]
							fulltext = ""
                                                        if  links.is_a? String
                                                          fulltext = links
                                                        elsif links.is_a? Array
                                                          links.each do |link|
								fulltext += link["href"]
                                                           end
                                                          end
							entry(protocol,from,to,date,fulltext)
						end
					end
				end		
			end # each entry
		end # entries is array
		if(events)
			events.each do |event|
				who = event["sender"]
				whenn = event["time"]
				what = event["type"];
				if(!what.casecmp "windowopened")
					ewhat = "open";
				end
				if(!what.casecmp "windowclosed")
					ewhat = "close";
				end
				if(what.eql? "offline")
					ewhat = "sign off";
				end
				if(what.eql? "disconnected")
					ewhat = "sign off"
				end
				if(!what.eql? "chat-error")
					event(protocol,who,whenn,ewhat)
				end
				
			end
		end
		statuses = xml["status"];
		if(statuses)
			statuses.each do |status|
				who = status["sender"];
				whenn = status["time"];
				what = status["type"];
				if(what.eql? "available")
					what = "back"
				end
				if(what.eql? "online")
					what = "sign on"
				end
				if(what.eql? "offline")
					what = "sign off"
				end
				if(what.eql? "disconnected")
					what = "sign off"
				end
				if(!what)
					what = "sign on"
				end

				event(protocol,who,whenn,what)
			end
		end
		
		return true;

	end # process

	def entry(protocol,from,to,date,text)
		date.sub!(/T/,' ');
		protocol = normalize_protocol(protocol)
		#puts "#{protocol}: #{from} to #{to} : #{text}"
		record_entry(@dbh,protocol,from,to,date,text);
	end

	def event(protocol,who,whenn,what)
		if(what && who && whenn)
			protocol = normalize_protocol(protocol)
			if(valid_event_type(what))
				record_event(@dbh,protocol,who,what,whenn)
			end
		else
			puts "Event: #{who} #{whenn} #{what}"
		end
	end

	def normalize_protocol(protocol)
		if(protocol.eql?"Yahoo!")
			return "Yahoo"
		end
		return protocol
	end
end



