# frozen_string_literal: true

require './src/constants.rb'
require './src/finder.rb'

if ARGV.empty?
  puts(ERR_MISSING_ARG)
  exit
end

ARGV.each do |dir_path|
  finder = Finder.new(dir_path)
  puts(finder.find_todos)
end
