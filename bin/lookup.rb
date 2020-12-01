#!/usr/bin/env ruby

require_relative '../lib/bam_lookup.rb'

require 'pry'

BamLookup.configure do |conf|
  conf.file_directory = "#{File.expand_path('~')}/Documents/Banque"
end

retreiver = BamLookup::Cli.new
retreiver.lookup
