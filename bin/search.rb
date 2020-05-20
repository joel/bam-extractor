#!/usr/bin/env ruby

require_relative '../lib/extract_value.rb'

require 'pry'

retreiver = ExtractValue::Ui.new
retreiver.search
