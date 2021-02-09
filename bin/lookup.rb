#!/usr/bin/env ruby

require_relative '../lib/bam_lookup.rb'

begin
  require 'pry'
rescue LoadError
end

BamLookup.configure do |conf|
  conf.file_directory = "#{File.expand_path('~')}/Documents/Banque"
end

retreiver = BamLookup::Cli.new
retreiver.lookup
