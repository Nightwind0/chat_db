require 'digest/sha2'

class Traverser

	def initialize(dbh,filehandler,import_id)
		@dbh = dbh
		@handler = filehandler
		@import_id  = import_id
		@handler.set_import_id(@import_id)
		@file_handled = dbh.prepare("select count(*) from files where filename = ? and digest = ?");
		@handle_file = dbh.prepare("insert into files (filename,digest,kimport) values (?,?,?)");
	end

	def do_file (path)
		return @handler.process(@dbh,path)
	end

	def do_dir ( directory )
		dir = Dir.new(directory).entries
		dir.each do |entry|
			if(File.directory?(directory + '/' +entry))
				if(entry != "." && entry != "..")
					puts "Entering dir: #{entry}"
					do_dir(directory+'/'+entry)
				end
			else
				path = directory + '/' + entry
				puts "File named: #{path}"
				digest = Digest::SHA2.hexdigest(File.read(path))
				success = false
				if(!file_handled?(entry,digest))
					begin
						success = do_file(path)
					rescue RDBI::Error => e
						puts "error"
					rescue SignalException => se
						raise "We get signal!"
					rescue Exception => e
						puts e.message
						puts e.backtrace
					end
					if(success)
						record_file(entry,digest, @import_id)
					else
						puts "File not handled"
					end
				else
					puts "Skipping file already seen."
				end
			end
		end
	end


private
	def record_file(filename, digest, import_id)
		@handle_file.execute(filename,digest,import_id);
	end

	def file_handled?(filename, digest)
		res = @file_handled.execute(filename,digest)
		row = res.fetch(:first)
		return row[0] > 0 
	end

end



