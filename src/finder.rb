# frozen_string_literal: true

class Finder

    TODO_REGEX = /TODO/

    def initialize(dir_path)
        @dir_path = File.expand_path(dir_path)
    end

    # Call this method to begin the process of finding TODOs.
    def find_todos()
        raise "The path you provided doesn't exist: #{@dir_path}" unless File.exist?(@dir_path)
        raise "The path you provided isn't a directory: #{@dir_path}" unless File.directory?(@dir_path)

        Finder.find_todos_in_dir(@dir_path)
    end

    # Assumption: Provided path is absolute, and a directory (not a file).
    # Will return array of absolute paths.
    def self.find_todos_in_dir(abs_dir_path)
        Dir.children(abs_dir_path)
            .reject do |subpath| subpath[0] == '.' end
            .map do |subpath| File.join(abs_dir_path, subpath) end
            .select do |next_level_path| File.exists?(next_level_path) end # should not be needed, but for good measure
            .flat_map do |next_level_path|
                if File.directory?(next_level_path)
                    find_todos_in_dir(next_level_path)
                elsif File.file?(next_level_path) && file_has_todos?(next_level_path)
                    next_level_path
                end
            end
            .reject do |result_path| result_path == nil end
    end

    # Given a file path, returns whether the file contains TODOs.
    # Assumption: file_path exists and is a file (not a directory).
    def self.file_has_todos?(file_path)
        any_line_has_todos?(
            File.foreach(file_path)
        )
    end
    
    # Accepts an enumerator of strings, each representing a line in a file.
    # Returns true if any string has TODO.
    def self.any_line_has_todos?(lines_enumerator)
        lines_enumerator
            .select(&:valid_encoding?)
            .grep(TODO_REGEX)
            .any?
    end
end