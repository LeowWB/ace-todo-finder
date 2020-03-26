# frozen_string_literal: true

require './src/constants.rb'

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
      .map do |line|
        Finder.line_to_comment(line)
      end
      .grep(TODO_REGEX)
      .any?
  end

  # given a line of code, returns only the commented portion of the line
  def self.line_to_comment(line)
    return '' unless line.include?('#')

    hash_indices = Finder.find_all_hashes(line)
    str_indices = Finder.find_all_string_lits(line)
    comment_index = Finder.find_comment_index(hash_indices, str_indices)

    if comment_index
      line[comment_index..-1]
    else
      ''
    end
  end

  # given a string that represents a line of code with a comment,
  # finds the point in the code where the comment begins.
  # input: 2 arrays representing the indices of hashes and string literals
  # output: the index of the first hash that's not in a string literal
  def self.find_comment_index(hash_indices, str_indices)
    hash_indices.each do |i|
      is_in_str = false
      str_indices.each do |j|
        if i >= j[0] && i <= j[1]
          is_in_str = true
          break
        end
      end
      return i unless is_in_str
    end
    nil # explicitly return nil
  end

  # given a string representing a code line, return indices of string literals
  # returned value will be array of arrays; each sub-array has 2 elements:
  # the start and end indices of the string literals
  def self.find_all_string_lits(str)
    rv = []
    cur_str_ind = -1
    in_str = false
    str_delim = "'"
    (0..str.length - 1).each do |i|
      char = str[i]
      if in_str
        if char == str_delim
          in_str = false
          rv.append([cur_str_ind, i])
          cur_str_ind = -1
        end
      elsif ["'", '"'].include?(char)
        in_str = true
        str_delim = char
        cur_str_ind = i
      end
    end
    rv
  end

  # given a string, returns the indices of all hashes in the string
  def self.find_all_hashes(str)
    rv = []
    (0..str.length - 1).each do |i|
      rv.append(i) if str[i] == '#'
    end
    rv
  end
end
