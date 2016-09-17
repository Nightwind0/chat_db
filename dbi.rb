#!/usr/bin/ruby
require 'rubygems'
gem 'dbi'
require 'dbi'

begin
dbh = DBI.connect('DBI:Mysql:ro_chatdb:mysql.rechargeableonion.com','chatdb_user','')


sth = dbh.execute("select sname from protocols")
sth.fetch do |row|
	puts row[0]
end
sth.finish






rescue DBI::DatabaseError => e
     puts "An error occurred"
     puts "Error code: #{e.err}"
     puts "Error message: #{e.errstr}"
ensure
     # disconnect from server
     dbh.disconnect if dbh
end
