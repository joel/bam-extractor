#!/usr/bin/env fish

function exists
  command -v $argv[1] >/dev/null 2>&1
end

if test exists 'ruby'
  echo 'Your system does not have rbenv installed'
end

if !exists 'rbenv'
  echo 'Your system does not have rbenv installed'
end

if exists 'rbenv'
  set -l RBENV_VERSION 2.7.2
end

## TODO: make the all direction in the path
bundle exec ruby ~/Documents/Banque/bam_lookup/bin/search.rb $argv
