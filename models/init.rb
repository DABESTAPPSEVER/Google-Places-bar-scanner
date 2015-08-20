DB = Sequel.connect(
	:adapter => 'mysql',
	:user => ENV['MYSQL_USERNAME'],
	:password => ENV['MYSQL_PASSWORD'],
	:host => ENV['MYSQL_HOST'],
	:database => ENV['MYSQL_DATABASE']
)

DB.create_table? :GooglePlaces do 
	primary_key :Row
	varchar :ID, :unique=>true, :null=>false
	varchar :Name, :null=>false
	Float :Latitude, :null=>false
	Float :Longitude, :null=>false
	varchar :Street, :null=>false
	varchar :City, :null=>false
	varchar :State, :null=>false
	varchar :Zip, :null=>false
end

require_relative 'classes.rb'