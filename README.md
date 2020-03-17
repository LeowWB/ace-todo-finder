## TODO Finder

It's common to see `TODO`s in code. It's also common for `TODO`s to remain as to-dos for a long time. One way we can solve this problem is to have a service that runs through all files in a given directory and checks for any instances of the key-phrase `TODO`, flagging each one of them out for humans to continue working on them.

This repository contains a Ruby script that, when given a directory, produces a list of all files (using their absolute paths) containing the keyword `TODO` in them. This includes files in the immediate directory, sub-directories, and so on.

## Setup
1. Clone this repository from the following URL: `https://github.com/LeowWB/ace-todo-finder.git`
2. Navigate to the repository root directory (`ace-todo-finder`) using your shell
3. Ensure you have Ruby installed on your device, as well as an internet connection
4. Execute `gem install bundler`
5. Execute `bundler install`

And you're done!

## Usage 
1. Navigate to the repository root directory (`ace-todo-finder`) using your shell
2. Execute `ruby src/main.rb [d]`, where `[d]` is the directory in which you wish to run the script, enclosed by quotation marks

Example: `ruby src/main.rb "."`

## Testing
Files related to testing can be found in `ace-todo-finder/test`. The `spec` subdirectory contains [RSpec](https://rspec.info/) test cases, while the `test_cases` directory contains a mock filesystem to be used for testing.

To run all tests:
1. Navigate to the repository root directory (`ace-todo-finder`) using your shell
2. Execute `rspec test/spec`

## Notes
* The script, by design, ignores all files and directories which begin with `.` (such as `.git` or `.gitignore`)
* The script only finds instances of the string `TODO` - strings such as `todo`, while similar, will not be flagged
