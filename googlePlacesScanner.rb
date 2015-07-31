[
	'mechanize',
	'json',
	'pp'
].each{|g|
	require g
}

[
	'models/init',
	'helpers/methods'
].each{|rb|
	require_relative rb+'.rb'
}

# SET UP AGENT
p "SETTING UP AGENT"
agent = Mechanize.new
agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Get around site's SSL problems

url = 'https://maps.googleapis.com/maps/api/place/textsearch/json?'
File.open('zipCodes.txt','r').readlines[0..-1].each{|zipCode|
	zipCode = zipCode.strip
	zipCode = '33401'

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
