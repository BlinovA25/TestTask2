class Product
  attr_accessor :name, :price, :picture

  def initialize(input_name,input_price,input_picture)
    @name = input_name
    @price = input_price
    @picture = input_picture
  end

  def show
    puts "Product: #{name}/#{price}/#{picture}"
  end
end