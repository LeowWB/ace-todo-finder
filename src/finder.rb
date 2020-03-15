# frozen_string_literal: true

# work only with abs paths

TODO_STRING = 'TODO'

def find_todos(dir_path)
    find_todos_abs(
        File.expand_path(
            dir_path
        )
    )
end

def find_todos_abs(abs_dir_path)
    result = []
    Dir.entries(dir_path).each do |next_level_path|
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
end
