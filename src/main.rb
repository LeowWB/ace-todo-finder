# frozen_string_literal: true

TODO_STRING = 'TODO'

def find_todos(dir_path)
    result = []
    get_paths_in_dir(dir_path).each do |subpath|
        if File.directory?(subpath)
            result += find_todos(subpath)
        elsif File.file?(subpath) && file_has_todos?(subpath)
            result.append(
                join_paths(
                    dir_path,
                    subpath
                )  
            )
        else
            raise "Path is neither directory nor file? (#{  "TODO get abs path"  })"
        end
    end

    result
end

def join_paths(dir_path, file_path)
    dir_path + file_path
end

def get_paths_in_dir(dir_path)
    Dir.entries(dir_path)
end

def file_has_todos?(file_path)
end
