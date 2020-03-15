load "finder.rb"

if ARGV.length < 1
    puts("Missing directory argument(s)")
    # TODO exit
end

ARGV[1..-1].each do |dir_path|
    puts(find_todos(dir_path))
end
