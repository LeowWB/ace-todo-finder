# frozen_string_literal: true

require 'set'
require './src/finder.rb'

TEST_CASE_DIR = "./test/test_cases/"

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
            context 'no TODO' do
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
                            ['the quick brown fox jumps TODO over the lazy dog'],
                            true
                        )
                    end
                end

                context 'at start of line' do
                    it 'returns true' do
                        any_line_has_todos_test_helper(
                            ['TODO over the lazy dog'],
                            true
                        )
                    end
                end

                context 'at end of line' do
                    it 'returns true' do
                        any_line_has_todos_test_helper(
                            ['the quick brown fox jumps TODO'],
                            true
                        )
                    end
                end

                context 'as only content in line' do
                    it 'returns true' do
                        any_line_has_todos_test_helper(
                            ['TODO'],
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
                        ['the', 'quick', 'brown'],
                        false
                    )
                end
            end

            context 'with all TODO' do
                it 'returns true' do
                    any_line_has_todos_test_helper(
                        ['theTODO', 'TODO quick', 'brTODOown'],
                        true
                    )
                end
            end

            context 'with one TODO' do
                it 'returns true' do
                    any_line_has_todos_test_helper(
                        ['the', 'quick', 'brTODOown', 'fox'],
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
                    TEST_CASE_DIR + "file_without_todo.txt",
                    false
                )
            end
        end

        context 'given file with todos' do
            it 'returns true' do
                file_has_todos_helper(
                    TEST_CASE_DIR + "file_with_todo.txt",
                    true
                )
            end
        end

        context 'given file with invalid utf8 data' do
            it 'does not give an error' do
                expect do
                    Finder.file_has_todos?(
                        TEST_CASE_DIR + "invalid_utf8_file"
                    )
                end.not_to raise_error
            end
        end
    end

    describe 'find_todos' do
        context 'given a directory' do
            it 'returns array of files containing "TODO"' do
                file_with_todo = [File.expand_path(
                    TEST_CASE_DIR + "directory/file_with_todo.txt"
                )]
                expect(Finder
                        .new(TEST_CASE_DIR + "directory/")
                        .find_todos
                ).to eq file_with_todo
            end
        end

        context 'given a directory with nested subdirectories' do
            it 'returns array of files containing "TODO"' do
                files_with_todo = [
                    "directory/file_with_todo.txt",
                    "file_with_todo.txt"
                ].map do |path|
                    File.expand_path(TEST_CASE_DIR + path)
                end

                expect(Finder
                        .new(TEST_CASE_DIR)
                        .find_todos
                        .to_set
                ).to eq files_with_todo.to_set
            end
        end

        context 'given a non-existent directory' do
            non_existent_dir_path = TEST_CASE_DIR + "non_existent_dir/"
            it 'raises an exception' do
                expect do
                    Finder
                        .new(non_existent_dir_path)
                        .find_todos
                end.to raise_error having_attributes(
                    message: "The path you provided doesn't exist: #{File.expand_path(non_existent_dir_path)}"
                )
            end
        end

        context 'given a file path (not a directory)' do
            file_path = TEST_CASE_DIR + "file_with_todo.txt"
            it 'raises an exception' do
                expect do
                    Finder
                        .new(file_path)
                        .find_todos
                end.to raise_error having_attributes(
                    message: "The path you provided isn't a directory: #{File.expand_path(file_path)}"
                )
            end
        end

        context 'given a directory with no TODOs at all' do
            dir_path = TEST_CASE_DIR + "directory/directory_without_todos"
            it 'returns an empty array' do
                expect(Finder
                        .new(dir_path)
                        .find_todos
                ).to eq []
            end
        end
    end
end

def file_has_todos_helper (file_path, expected)
    result = Finder.file_has_todos?(file_path)
    expect(result).to be expected
end


def any_line_has_todos_test_helper (array, expected)
    result = Finder.any_line_has_todos?(array.each)
    expect(result).to be expected
end
