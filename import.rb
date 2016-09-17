#!/usr/bin/ruby
require 'rubygems'
gem 'rdbi'
require 'rdbi'
require 'rdbi-driver-postgresql'
require_relative 'Traverser.rb'
require_relative 'AdiumHandler.rb'
require_relative 'PurpleHandler.rb'
require_relative 'GaimHandler.rb'

directory = ARGV[1]
handlertype = ARGV[0]
homedb = 'DBI:Pg:chatdb:localhost'
arguments = ARGV

begin

#dbh = DBI.connect('DBI:Mysql:ro_chatdb:mysql.rechargeableonion.com','chatdb_user','wwccppa')
dbh = RDBI.connect(RDBI::Driver::PostgreSQL,:database => 'chatdb', :host => 'localhost', :user => 'chatdbuser', :password => 'wwccppa')
#dbh = DBI.connect('DBI:SQLite3:chatdb.db')
handler = case handlertype
when "Adium" then Adium2Handler.new(dbh,arguments) 
when "Purple" then PurpleHandler.new(dbh,arguments)
when "Gaim" then GaimHandler.new(dbh,arguments)
end


handler_name = handler.name

dbh.execute("insert into imports (shandler) values ('#{handler_name}');")
result = dbh.execute("select max(nkey) from imports");

row = result.as(:Array).fetch(:first)

import_id = row[0]

puts "Import id: #{import_id}"

traverser = Traverser.new(dbh,handler,import_id)

traverser.do_dir(directory);


rescue RDBI::Error => e
     puts "An error occurred"
     #puts "Error code: #{e.err}"
     puts "Error message: #{e.message}"
rescue Exception => e
    puts "Exception: #{e.message}"   
  puts e.backtrace
ensure
     # disconnect from server
     dbh.disconnect if dbh
end









