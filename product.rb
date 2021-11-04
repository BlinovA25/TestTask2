class Product
  attr_accessor :name, :price, :picture

  def initialize(a,b,c)
    @name = a
    @price = b
    @picture = c
  end

  def show
    puts "Product: #{name}/#{price}/#{picture}"

  end
end