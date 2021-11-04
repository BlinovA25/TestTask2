
class WorkWithFile
  def self.add_to_file (filename,name,price,picture)
    products = []
    products.push name: name, price: price, picture: picture
    CSV.open(filename, 'a', write_headers: false, headers: products.first.keys) do |csv|
      products.each do |product|
        csv << product.values
      end
    end
  end

  def self.create_file (filename)
    products = []
    products.push name: "name", price: "price", picture: "picture"
    CSV.open(filename, 'w', write_headers: false, headers: products.first.keys) do |csv|
      products.each do |man|
        csv << man.values
      end
    end
    puts "File #{filename} was successfully created!"
  end
end