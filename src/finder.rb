# frozen_string_literal: true

TODO_REGEX = /TODO/.freeze
ERR_PATH_DOESNT_EXIST = "The path you provided doesn't exist: "
ERR_PATH_NOT_DIR = "The path you provided isn't a directory: "

# Main class responsible for performing the TODO-finding
class Finder
  def initialize(dir_path)
    @dir_path = File.expand_path(dir_path)
  end

  # Call this method to begin the process of finding TODOs.
  def find_todos
    raise ERR_PATH_DOESNT_EXIST + @dir_path unless File.exist?(@dir_path)
    raise ERR_PATH_NOT_DIR + @dir_path unless File.directory?(@dir_path)

    Finder.find_todos_in_dir(@dir_path)
  end

  # Given an absolute directory path, returns absolute paths of all files
  # with TODOs.
  def self.find_todos_in_dir(abs_dir_path)
    Dir
      .children(abs_dir_path)
      .reject { |path| path[0] == '.' }
      .map { |path| File.join(abs_dir_path, path) }
      .select { |path| File.exist?(path) } # for good measure
      .flat_map { |path| find_todos_in_path(path) }
      .reject(&:nil?)
  end

  # Helper method for find_todos_in_dir. Accepts an input absolute path. If the
  # path is a directory, returns the absolute paths of all files with TODOs.
  # Else, returns the path itself.
  def self.find_todos_in_path(abs_path)
    if File.directory?(abs_path)
      find_todos_in_dir(abs_path)
    elsif File.file?(abs_path) && file_has_todos?(abs_path)
      abs_path
    end
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
