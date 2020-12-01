#!/usr/bin/env ruby

require_relative '../lib/bam_lookup.rb'

require 'pry'

retreiver = BamLookup::Cli.new
retreiver.search
