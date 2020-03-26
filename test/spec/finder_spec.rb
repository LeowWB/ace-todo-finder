# frozen_string_literal: true

require 'set'
require './src/finder.rb'

TEST_CASE_DIR = './test/test_cases/'

describe Finder do
  describe '.any_line_has_todos?' do
    context 'given empty enumerator' do
      it 'returns false' do
        any_line_has_todos_test_helper(
          [],
          false
        )
      end
    end

    context 'given singleton enumerator' do
      context 'with no TODO' do
        it 'returns false' do
          any_line_has_todos_test_helper(
            ['the quick brown fox jumps over the lazy dog'],
            false
          )
        end
      end

      context 'with TODO' do
        context 'surrounded by text' do
          it 'returns true' do
            any_line_has_todos_test_helper(
              ['the quick brown fox jumps #TODO over the lazy dog'],
              true
            )
          end
        end

        context 'at start of line' do
          it 'returns true' do
            any_line_has_todos_test_helper(
              ['#TODO over the lazy dog'],
              true
            )
          end
        end

        context 'at end of line' do
          it 'returns true' do
            any_line_has_todos_test_helper(
              ['the quick brown fox jumps #TODO'],
              true
            )
          end
        end

        context 'as only content in line' do
          it 'returns true' do
            any_line_has_todos_test_helper(
              ['#TODO'],
              true
            )
          end
        end

        context 'not immediately following hash' do
          it 'returns true' do
            any_line_has_todos_test_helper(
              ['hello', '#worldTODO'],
              true
            )
          end
        end
      end
    end

    context 'given enumerator with multiple elements' do
      context 'with no TODO' do
        it 'returns false' do
          any_line_has_todos_test_helper(
            %w[the quick brown],
            false
          )
        end
      end

      context 'with TODO but not in a comment' do
        it 'returns false' do
          any_line_has_todos_test_helper(
            %w[the quick brown TODO],
            false
          )
        end
      end

      context 'with all TODO' do
        it 'returns true' do
          any_line_has_todos_test_helper(
            ["the#TODO","#TODOquick","br#TODOown"],
            true
          )
        end
      end

      context 'with one TODO' do
        it 'returns true' do
          any_line_has_todos_test_helper(
            ["the", "quick", "br#TODOown", "fox"],
            true
          )
        end
      end
    end
  end

  describe '.file_has_todos?' do
    context 'given file without todos' do
      it 'returns false' do
        file_has_todos_helper(
          TEST_CASE_DIR + 'file_without_todo.txt',
          false
        )
      end
    end

    context 'given file with todos' do
      it 'returns true' do
        file_has_todos_helper(
          TEST_CASE_DIR + 'file_with_todo.txt',
          true
        )
      end
    end

    context 'given file with invalid utf8 data' do
      it 'does not give an error' do
        expect do
          Finder.file_has_todos?(
            TEST_CASE_DIR + 'invalid_utf8_file'
          )
        end.not_to raise_error
      end
    end
  end

  describe 'find_todos' do
    context 'given a directory' do
      it 'returns array of files containing "TODO"' do
        file_with_todo = [File.expand_path(
          TEST_CASE_DIR + 'directory/file_with_todo.txt'
        )]
        expect(
          Finder
            .new(TEST_CASE_DIR + 'directory/')
            .find_todos
        ).to eq file_with_todo
      end
    end

    context 'given a directory with nested subdirectories' do
      it 'returns array of files containing "TODO"' do
        files_with_todo = [
          'directory/file_with_todo.txt',
          'file_with_todo.txt',
          'ruby_files/file_multiple_hashes.rb',
          'ruby_files/file_todo_comment.rb',
          'ruby_files/file_todo_middle_of_comment.rb',
          'ruby_files/file_todo_str_lit_in_comment.rb'
        ].map do |path|
          File.expand_path(TEST_CASE_DIR + path)
        end

        expect(
          Finder
            .new(TEST_CASE_DIR)
            .find_todos
            .to_set
        ).to eq files_with_todo.to_set
      end
    end

    context 'given a non-existent directory' do
      non_existent_dir_path = TEST_CASE_DIR + 'non_existent_dir/'
      it 'raises an exception' do
        expect do
          Finder
            .new(non_existent_dir_path)
            .find_todos
        end.to raise_error having_attributes(
          message: ERR_PATH_DOESNT_EXIST +
            File.expand_path(non_existent_dir_path)
        )
      end
    end

    context 'given a file path (not a directory)' do
      file_path = TEST_CASE_DIR + 'file_with_todo.txt'
      it 'raises an exception' do
        expect do
          Finder
            .new(file_path)
            .find_todos
        end.to raise_error having_attributes(
          message: ERR_PATH_NOT_DIR + File.expand_path(file_path)
        )
      end
    end

    context 'given a directory with no TODOs at all' do
      dir_path = TEST_CASE_DIR + 'directory/directory_without_todos'
      it 'returns an empty array' do
        expect(
          Finder
          .new(dir_path)
          .find_todos
        ).to eq []
      end
    end
  end

  describe 'find_all_hashes' do
    context 'given string with no hashes' do
      it 'returns empty array' do
        expect(
          Finder.find_all_hashes("hello world")
        ).to eq []
      end
    end

    context 'given string with one hash' do
      it 'returns singleton array' do
        expect(
          Finder.find_all_hashes("hello#world")
        ).to eq [5]
      end
    end

    context 'given string with multiple hashes' do
      it 'returns array' do
        expect(
          Finder.find_all_hashes("hello#world#")
        ).to eq [5,11]
      end
    end
  end

  describe 'find_all_string_lits' do
    context 'given string with no string lits' do
      it 'returns empty array' do
        expect(
          Finder.find_all_string_lits("hello world")
        ).to eq []
      end
    end

    context 'given string with one string lit' do
      it 'returns singleton array' do
        expect(
          Finder.find_all_string_lits("hello 'world' hello")
        ).to eq [[6,12]]
      end
    end

    context 'given string with multiple string lits' do
      it 'returns array' do
        expect(
          Finder.find_all_string_lits("hello 'world' hello 'world'")
        ).to eq [[6,12],[20,26]]
      end
    end
  end

  describe 'line_to_comment' do
    context 'given line with no comment' do
      it 'returns empty string' do
        expect(
          Finder.line_to_comment('Hello world')
        ).to eq ''
      end
    end

    context 'given line with simple comment' do
      it 'returns the commented portion' do
        expect(
          Finder.line_to_comment('Hello world #hello')
        ).to eq '#hello'
      end
    end

    context 'given line with hashes in string literal' do
      it 'ignores the string literal' do
        expect(
          Finder.line_to_comment('Hello world "#hello" #hi')
        ).to eq '#hi'
      end
    end

    context 'given line with string literal in comment' do
      it 'returns the comment anyway' do
        expect(
          Finder.line_to_comment('Hello world #hell"o"')
        ).to eq '#hell"o"'
      end
    end
  end

end

def file_has_todos_helper(file_path, expected)
  result = Finder.file_has_todos?(file_path)
  expect(result).to be expected
end

def any_line_has_todos_test_helper(array, expected)
  result = Finder.any_line_has_todos?(array.each)
  expect(result).to be expected
end
