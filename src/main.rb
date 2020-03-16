load "finder.rb"

MISSING_ARG_ERR_MSG = "Missing directory argument(s).\nExample usage:\nruby main.rb './directory_name'"

if ARGV.length < 1
    puts(MISSING_ARG_ERR_MSG)
    exit
end

ARGV.each do |dir_path|
    puts(find_todos(dir_path))
end
