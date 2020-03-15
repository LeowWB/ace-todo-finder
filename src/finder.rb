# frozen_string_literal: true

TODO_REGEX = /TODO/

def find_todos(dir_path)
    find_todos_abs(
        File.expand_path(
            dir_path
        )
    )
end

def find_todos_abs(abs_dir_path)
    result = []
    Dir.entries(abs_dir_path).each do |subpath|
        next_level_path = File.join(abs_dir_path, subpath)        # TODO can replace with a map.
        raise "Subpath does not exist? (#{ next_level_path })" unless File.exist?(next_level_path)
        if File.directory?(next_level_path)
            result += find_todos_abs(next_level_path)
        elsif File.file?(next_level_path) && file_has_todos?(next_level_path)
            result.append(
                next_level_path
            )
        else
            raise "Path is neither directory nor file? (#{next_level_path})"
        end
    end

    result
end

def file_has_todos?(file_path)
    File
        .foreach(file_path)
        .grep(TODO_REGEX)
        .any?
end
