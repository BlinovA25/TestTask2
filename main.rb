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

#<ul class="attribute_radio_list pundaline-variations">

=begin
def one_product_page_parsing(filename, page_url)
  parsed_page = parsing_func(page_url + ".html")
  finded_name = parsed_page.xpath("//*[@class = 'product_main_name']/text()")#
  finded_picture = parsed_page.xpath("//*[@id = 'bigpic']/@src")
  #<span class="radio_label">6x300Grs</span>
  #
  # <li class="quantityDiscount_21300" data-real-discount-value="14.39"
  # data-discount-type="percentage" data-discount="2" data-discount-quantity="2">
  # <span class="variation-name"><span>x</span>2</span> <span class="variation-price">28.78 €</span>
  # <span class="variation-unit-price">14.39 €</span> <span class="variation-discount">- 0.59 € </span>
  # </li>
  #
  parsed_page.xpath("//*[@class = 'attribute_radio_list pundaline-variations']/@li").each { |li_object|
    finded_price = parsed_page.xpath('//span[contains(@class,"variation-price")]')[0].text #//*[@class = 'price_comb']/text()")
    finded_weigth = parsed_page.xpath('//span[contains(@class,"variation-name")]')[0].text
    add_to_file(filename, finded_name.to_s + " " + finded_weigth.to_s, finded_price, finded_picture)
  }
=end


def one_product_page_parsing(filename, page_url)
  parsed_page = parsing_func(page_url + ".html")
  finded_name = parsed_page.xpath("//*[@class = 'product_main_name']/text()")#
  finded_price = parsed_page.xpath("//*[@class = 'price_comb']/text()")
  finded_weigth = parsed_page.xpath("//*[@class = 'radio_label']/text()")
  finded_picture = parsed_page.xpath("//*[@id = 'bigpic']/@src")
  add_to_file(filename, finded_name.to_s + " " + finded_weigth.to_s, finded_price, finded_picture)
end


def one_site_page_parsing(filename, link_to_some_category)
  parsed_page = parsing_func(link_to_some_category)
  find_link_by_class = parsed_page.xpath("//*[@class = 'product_img_link pro_img_hover_scale product-list-category-img']/@href")
  link_list = find_link_by_class.to_s.split(/.html/)
  puts "Start parsing products pages:"
  link_list.each { |url_in_link_list|
    one_product_page_parsing(filename, url_in_link_list)
  }
end

def main
  puts "Enter file name(format -- name_of_file.csv):"
  filename = gets.chomp
  link_to_some_category = enter
  puts "Program starts it's work!"
  #link_to_some_category = "https://www.petsonic.com/comida-humeda-para-perros/"
  create_file(filename)

  check_link = ""
  (1..100).each { |page_num|
    result_link_to_category = link_to_some_category + "?p=#{page_num}"
    if(result_link_to_category == check_link)
      puts "Program finished it's work!"
      return
    end
    one_site_page_parsing(filename, result_link_to_category)
    check_link = result_link_to_category
  }

end

#create_file("TestParse.csv")
#one_product_page_parsing("TestParse.csv", "https://www.petsonic.com/farmina-nd-dog-quinoa-skin-coat-arenque-comida-humeda-para-perros-6x285grs")

main