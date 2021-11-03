require 'curb'
require 'nokogiri'
require 'csv'

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

def parsing_func(url)
  page = Curl.get(url) do |curl|
    curl.ssl_verify_peer = false
    curl.ssl_verify_host = 0
  end
  parsed_page = Nokogiri::HTML(page.body_str)
  puts "Congrats! #{url} page have been parsed!"
  return parsed_page
end

def add_to_file (filename,name,price,picture)
  products = []
  products.push name: name, price: price, picture: picture
  CSV.open(filename, 'a', write_headers: false, headers: products.first.keys) do |csv|
    products.each do |product|
      csv << product.values
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

def one_site_page_parsing(filename, link_to_some_category)
  parsed_page = parsing_func(link_to_some_category)
  find_link_by_class = parsed_page.xpath("//*[@class = 'product_img_link pro_img_hover_scale product-list-category-img']/@href")
  link_list = find_link_by_class.to_s.split(/.html/)
  puts "Start parsing products page:"
  link_list.each { |url_in_link_list|
    one_product_page_parsing(filename, url_in_link_list)
  }
end

def one_product_page_parsing(filename, page_url)
  parsed_page = parsing_func(page_url + ".html")
  finded_name = parsed_page.xpath("//h1[@class = 'product_main_name']/text()")
  finded_picture = parsed_page.xpath("//*[@id = 'bigpic']/@src")
  find = parsed_page.xpath("//li[contains(@class,'quantityDiscount')]")
  @prices = find.xpath("//span[@class = 'variation-price']/text()")
  @weigths = find.xpath("//span[@class = 'variation-name']/text()")
  @pandv = @prices.zip(@weigths).map do |finded_price,finded_weigth|
    add_to_file(filename, "#{finded_name}  X#{finded_weigth} ", finded_price, finded_picture)
  end
end

def show_title(page_url)
  page = parsing_func(page_url)
  title = page.xpath("//title/text()")
  return title
end

def main_parse(filename, link_to_category)
  num_of_produts = parsing_func(link_to_category).xpath('//input[@id = "nb_item_bottom"]/@value').text.to_i
  num_of_pages = (num_of_produts/25.0).ceil
  one_site_page_parsing(filename, link_to_category)
  (2..num_of_pages).each do |page_num|
    result_link_to_category = link_to_category + "?p=#{page_num}"
    one_site_page_parsing(filename, result_link_to_category)
  end
end

def main
  puts "Enter file name(format -- name_of_file.csv):"
  filename = gets.chomp
  link_to_some_category = enter
  puts "Program starts it's work!"
  create_file(filename)
  main_parse(filename, link_to_some_category)
  puts "Program finished it's work!"
end

main
#filename = ParseData.csv
#link_to_some_category = "https://www.petsonic.com/comida-humeda-para-perros/"