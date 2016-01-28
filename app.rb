require 'mechanize'
require 'date'
require 'time'
require 'data_mapper'

def parse_status(strike, sale_date)
  return 'Cancelled' if strike
  Date.today > sale_date ? 'Completed' : 'Active'
end

DataMapper.setup(:default, 'mysql://test:123456@localhost/ruby_test')

class Property
  include DataMapper::Resource
  property :id,               Serial
  property :file,             Text
  property :sale_date,        Date
  property :sale_time,        Time
  property :property_address, Text
  property :city,             Text
  property :jurisdiction,     Text
  property :state,            Text
  property :zip,              Text
  property :deposit,          Text
  property :status,           Text
end

DataMapper.finalize
DataMapper.auto_migrate!

puts "Loading web page..."
agent = Mechanize.new
page = agent.get('http://rosenberg-assoc.com/foreclosure/listings_new.asp')
rows = page.css('.right_panel').search('//table//table[2]//tr')
puts "Page loaded.\n"

rows[1..-4].each do |row|
  if row.inner_text.strip.size > 0

    font = row.search('.//td[1]//font/s')
    striked = not(font.empty?) # true for active, false (striked) for cancelled

    row_data = []
    row.children.each do |rec| # getting data from html
      text = rec.inner_text.strip
      row_data << text unless text == ''
    end

    # storing data to hash with proper field names
    row_hash = { :file => row_data.shift } # create hash and store first value
    # next we popping data from end of array
    [:deposit, :zip, :state, :jurisdiction, :city, :property_address].each { |field| row_hash[field] = row_data.pop }
    # finally we can see if row had sale_time value
    if row_data.size == 2
      row_hash[:sale_time] = Time.strptime(row_data.join(' '), '%m/%d/%Y %r')
      row_hash[:sale_date] = row_hash[:sale_time].to_date
    else
      row_hash[:sale_date] = Date.strptime(row_data.shift, '%m/%d/%Y')
    end


    row_hash[:status] = parse_status(striked, row_hash[:sale_date])

    prop = Property.create(row_hash)
    puts "Property #{prop.file} saved"
  end
end

puts 'All done.'
