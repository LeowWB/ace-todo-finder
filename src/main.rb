load "finder.rb"

if ARGV.length < 1
    # TODO make msg nicer
    puts("Missing directory argument(s)")
    exit
end

ARGV[1..-1].each do |dir_path|
    puts(find_todos(dir_path))
end
