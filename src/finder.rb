# frozen_string_literal: true

class Finder

    TODO_REGEX = /TODO/

    def initialize(dir_path)
        @dir_path = dir_path
    end

    def find_todos()
        raise "The path you provided doesn't exist: #{@dir_path}" unless File.exist?(@dir_path)
        raise "The path you provided isn't a directory: #{@dir_path}" unless File.directory?(@dir_path)

        find_todos_abs(
            File.expand_path(
                @dir_path
            )
        )
    end

    def find_todos_abs(abs_dir_path)
        result = []
        Dir.children(abs_dir_path).each do |subpath|
            next if subpath[0] == '.'
            next_level_path = File.join(abs_dir_path, subpath)        # TODO can replace with a map.
            raise "Subpath does not exist? (#{ next_level_path })" unless File.exist?(next_level_path)
            if File.directory?(next_level_path)
                result += find_todos_abs(next_level_path)
            elsif File.file?(next_level_path)
                result.append(
                    next_level_path
                ) if file_has_todos?(next_level_path)
            else
                raise "Path is neither directory nor file? (#{next_level_path})"
            end
        end

        result
    end

    def file_has_todos?(file_path)
        any_line_has_todos?(
            File.foreach(file_path)
        )
    end
    
    def any_line_has_todos?(lines_enumerator)
        lines_enumerator
            .grep(TODO_REGEX)
            .any?
    end
end