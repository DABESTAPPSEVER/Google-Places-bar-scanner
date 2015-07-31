# MYSQL CONNECT INFO HERE

DB.create_table? :GooglePlaces do 
	primary_key :Row
	varchar :ID, :unique=>true, :null=>false
	varchar :Name, :null=>false
	varchar :Street, :null=>false
	varchar :City, :null=>false
	Integer :Zip, :null=>false
	varchar :State, :null=>false
	Float :Latitude, :null=>false
	Float :Longitude, :null=>false
end