require 'curb'
require 'nokogiri'
require 'csv'

def enter
  r = true
  while(r) do
    puts "Enter the link of webpage:"
    url = gets.chomp
    puts "Your link -- url\nEnter Y to continue/N to rewrite"
    res = gets.chomp
    if res == 'Y'
      r = false
      return url
    end
  end
end

def parsing_func(url)
  page = Curl.get(url)
  parsed_page = Nokogiri::HTML(page.body_str)
  puts "Congrats! #{url} page have been parsed!"
  return parsed_page
end

def add_to_file (filename,name,price,picture)
  products = []
  products.push name: name, price: price, picture: picture
  CSV.open(filename, 'a', write_headers: false, headers: products.first.keys) do |csv|
    products.each do |man|
      csv << man.values
    end
  end
end

def create_file (filename)
  products = []
  products.push name: "name", price: "price", picture: "picture"
  CSV.open(filename, 'w', write_headers: false, headers: products.first.keys) do |csv|
    products.each do |man|
      csv << man.values
    end
  end
  puts "File #{filename} was successfully created!"
end

def one_page_parsing(filename, page_url)
  parsed_page = parsing_func(page_url + ".html")
  finded_name = parsed_page.xpath("//*[@class = 'product_main_name']/text()")#
  finded_weigth = parsed_page.xpath("//*[@class = 'radio_label']/text()")
  finded_price = parsed_page.xpath("//*[@class = 'price_comb']/text()")
  finded_picture = parsed_page.xpath("//*[@id = 'bigpic']/@src")
  add_to_file(filename, finded_name.to_s + " " + finded_weigth.to_s, finded_price, finded_picture)
end

def main
  puts "Enter file name(format -- name_of_file.csv):"
  filename = gets.chomp
  link_to_some_category = enter
  puts "Program starts it's work!"
  #link_to_some_category = "https://www.petsonic.com/comida-humeda-para-perros/"
  parsed_page = parsing_func(link_to_some_category)

  create_file(filename)

  find_link_by_class = parsed_page.xpath("//*[@class = 'product_img_link pro_img_hover_scale product-list-category-img']/@href")
  link_list = find_link_by_class.to_s.split(/.html/)

  puts "Start parsing products pages:"
  link_list.each { |url_in_link_list|
    one_page_parsing(filename, url_in_link_list)
    #puts "#{url_in_link_list} was parsed"
  }
  puts "Program finished it's work!"
end

main