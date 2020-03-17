# frozen_string_literal: true

load './src/finder.rb'

MISSING_ARG_ERR_MSG = 'Missing directory argument(s).\n' \
  "Example usage:\nruby main.rb './directory_name'"

if ARGV.empty?
  puts(MISSING_ARG_ERR_MSG)
  exit
end

ARGV.each do |dir_path|
  finder = Finder.new(dir_path)
  puts(finder.find_todos)
end
