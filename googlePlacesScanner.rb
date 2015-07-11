[
	'mechanize',
	'json'
].each{|g|
	require g
}
require_relative 'helpers/methods.rb'

# SET UP AGENT
p "SETTING UP AGENT"
agent = Mechanize.new
agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Get around site's SSL problems

url = 'https://maps.googleapis.com/maps/api/place/textsearch/json?'
File.open('zipCodes.txt','r').readlines[0..-1].each{|zipCode|
	zipCode = zipCode.strip

	# Skip Puerto Rican zip codes
	if(zipCode[0..1]==='00')
		next
	end

	getParamsHash = {
		'query'=>'*+in+'+zipCode,
		'key'=>ARGV[0],
		'type'=>'bar|night_club'
	}
	getParamsString = getParamsHash.map{|pvPair|
		param = pvPair[0]
		val = pvPair[1]
		param+'='+val.to_s
	}.join('&')
	
	fullURL = url+getParamsString
	getListings(agent, fullURL)
}
