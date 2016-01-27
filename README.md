It's solution for test task from one prospect on Upwork.com.

Task itself is here:

As a test task please write a Ruby command line script to grab the data from the following web page:
http://rosenberg-assoc.com/foreclosure/listings_new.asp
The script should loop through all the properties in the table and store each record into a mysql table called 'properties'.  
The columns of the mysql table should mirror the data in the table on the webpage (file, sale_date, sale_time, property_address, city, jurisdiction, state, zip, deposit, status).
While inserting the rows, set the status for each property.
The default status is 'Active'.
If the sale_date has already passed, the status should be 'Completed'.
If the row has a line strike through it, the status should be 'Cancelled'.

I use Mechanize to get web page, Nokogiri to work with DOM, Datamapper - to connect to MySQL database.
