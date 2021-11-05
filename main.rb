require 'curb'
require 'nokogiri'
require 'csv'
require 'yaml'

require_relative 'product'
require_relative 'parsing'
require_relative 'work_with_file'

def main
  params = YAML.load_file('params.yml')
  start = Time.now.to_i
  WorkWithFile.create_file(params['file'])
  Parsing.main_parse(params['file'], params['link'])
  finish = Time.now.to_i
  puts "Program finished it's work in #{finish - start} sec!"
end

main