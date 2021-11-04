require 'curb'
require 'nokogiri'
require 'csv'
require 'yaml'

require_relative 'parsing'
require_relative 'work_with_file'

def enter
  status = true
  while(status) do
    puts "Enter the link of webpage:"
    url = gets.chomp
    puts "Your link -- url\nEnter Y to continue/N to rewrite"
    agree = gets.chomp
    if agree == 'Y'
      status = false
      return url
    end
  end
end

def main
  #puts "Enter file name(format -- name_of_file.csv):"
  #filename = gets.chomp
  #link_to_some_category = enter
  #puts "Program starts it's work!"
  #
  params = YAML.load_file('')
  filename = params['file']
  link_to_some_category = params['link']
  WorkWithFile.create_file(filename)
  Parsing.main_parse(filename, link_to_some_category)
  puts "Program finished it's work!"
end

main
#filename = ParseData.csv
#link_to_some_category = "https://www.petsonic.com/comida-humeda-para-perros/"