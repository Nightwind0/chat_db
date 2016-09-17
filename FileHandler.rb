class FileHandler
	def initialize (dbh,arguments)
		@count_query = dbh.prepare("select count(*) from entries where sfrom=? and sto=? and ddate=? and kprotocol=? and stext=? limit 1"); 
		@entry_execute  = dbh.prepare("insert  into entries (sfrom,sto,ddate,kprotocol,stext, kimport) values (?,?,?,?,?,?)");
		@event_query = dbh.prepare("select count(*) from events where swho=? and kprotocol=? and dwhen=? and ewhat=? limit 1");
		@event_execute = dbh.prepare("insert  into events (swho,dwhen,kprotocol,ewhat,kimport) values(?,?,?,?,?)");
		@arguments = arguments
	end
	def name
		return "FileHandler"
	end

	def set_import_id(import_id)
		@import_id = import_id
	end

	def process (dbh, path)
		return false;
	end


	private

	def record_entry(dbh, protocol, from,to, whenn, text)
		res = @count_query.execute(from,to,whenn,protocol,text)
		row = res.fetch(:first)
		if(row[0] == 0)
			@entry_execute.execute(from,to,whenn,protocol,text,@import_id)
		end
	end


	def record_event(dbh,protocol,who,what,whenn)
		res = @event_query.execute(who,protocol,whenn,what)
		row = res.fetch(:first)
		if(row[0] == 0)
			@event_execute.execute(who,whenn,protocol,what,@import_id)
		end
	end
	
	def valid_event_type(what)
		case what
		when "sign off" then
			return true;
		when "sign on" then
			return true;
		when "back" then
			return true;
		when "idle" then
			return true;
		when "away" then
			return true;
		end
		return false;
	end
end
