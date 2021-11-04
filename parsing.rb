
# Добавление сущности класса -- строка 47
#
# Реализация многопоточности -- строки 30-36
#

require 'thread'

require_relative 'product'
require_relative 'work_with_file'

# модуль для функций, связанных с парсингом страниц и применением XPATH выражений
module Parsing
  def self.parsing_func(url)
    page = Curl.get(url) do |curl|
      curl.ssl_verify_peer = false
      curl.ssl_verify_host = 0
    end
    parsed_page = Nokogiri::HTML(page.body_str)
    puts "Congrats! #{url} page have been parsed!"
    return parsed_page
  end

  def self.one_site_page_parsing(filename, link_to_some_category)
    parsed_page = parsing_func(link_to_some_category)
    find_link_by_class = parsed_page.xpath("//*[@class = 'product_img_link pro_img_hover_scale product-list-category-img']/@href")
    link_list = find_link_by_class.to_s.split(/.html/)
    puts "Start parsing products page:"
    #Вызов функции парсинга одной страницы продукта теперь обёрнут в потоки
    threads = []
    link_list.each { |url_in_link_list|
      threads << Thread.new do
        one_product_page_parsing(filename, url_in_link_list)
      end
    }
    threads.map(&:join)
  end

  def self.one_product_page_parsing(filename, page_url)
    parsed_page = parsing_func(page_url + ".html")
    #finded_name = parsed_page.xpath("//h1[@class = 'product_main_name']/text()")
    #finded_picture = parsed_page.xpath("//*[@id = 'bigpic']/@src")
    find = parsed_page.xpath("//li[contains(@class,'quantityDiscount')]")
    @prices = find.xpath("//span[@class = 'variation-price']/text()")
    @weigths = find.xpath("//span[@class = 'variation-name']/text()")
    @pandv = @prices.zip(@weigths).map do |finded_price,finded_weigth|
      some_product = Product.new("#{parsed_page.xpath("//h1[@class = 'product_main_name']/text()")} X#{finded_weigth}", finded_price, parsed_page.xpath("//*[@id = 'bigpic']/@src"))
      WorkWithFile.add_to_file(filename, some_product.name, some_product.price, some_product.picture)
    end
  end

  def self.main_parse(filename, link_to_category)
    params = YAML.load_file('params.yml')
    num_of_produts = parsing_func(link_to_category).xpath('//input[@id = "nb_item_bottom"]/@value').text.to_i
    num_of_pages = (num_of_produts/params['num_of_products_on_page']).ceil
    one_site_page_parsing(filename, link_to_category)
    (2..num_of_pages).each do |page_num|
      result_link_to_category = link_to_category + "?p=#{page_num}"
      one_site_page_parsing(filename, result_link_to_category)
    end
  end

end