# frozen_string_literal: true

require './src/finder.rb'

describe Finder do
    
    describe '.any_line_has_todos?' do
        context 'given empty enumerator' do
            it 'returns false' do
                test_with_array(
                    [],
                    false
                )
            end
        end

        context 'given singleton enumerator' do
            context 'no TODO' do
                it 'returns false' do
                    test_with_array(
                        ['the quick brown fox jumps over the lazy dog'],
                        false
                    )
                end
            end

            context 'with TODO' do
                context 'surrounded by text' do
                    it 'returns true' do
                        test_with_array(
                            ['the quick brown fox jumps TODO over the lazy dog'],
                            true
                        )
                    end
                end

                context 'at start of line' do
                    it 'returns true' do
                        test_with_array(
                            ['TODO over the lazy dog'],
                            true
                        )
                    end
                end

                context 'at end of line' do
                    it 'returns true' do
                        test_with_array(
                            ['the quick brown fox jumps TODO'],
                            true
                        )
                    end
                end

                context 'as only content in line' do
                    it 'returns true' do
                        test_with_array(
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
                    test_with_array(
                        ['the', 'quick', 'brown'],
                        false
                    )
                end
            end

            context 'with all TODO' do
                it 'returns true' do
                    test_with_array(
                        ['theTODO', 'TODO quick', 'brTODOown'],
                        true
                    )
                end
            end

            context 'with one TODO' do
                it 'returns true' do
                    test_with_array(
                        ['the', 'quick', 'brTODOown', 'fox'],
                        true
                    )
                end
            end
        end
    end
end

def test_with_array(array, expected)
    result = Finder.any_line_has_todos?(array.each)
    expect(result).to be expected
end
