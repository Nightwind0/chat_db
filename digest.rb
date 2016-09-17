#!/usr/bin/ruby

require 'digest/sha2'
#digest = Digest::SHA2.new;

digest = Digest::SHA2.hexdigest(File.read(ARGV[0]))
puts digest