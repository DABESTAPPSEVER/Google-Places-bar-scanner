[
	'open-uri',
	'mechanize',
	'json'
].each{|g|
	require g
}

# SET UP AGENT
p "SETTING UP AGENT"
agent = Mechanize.new
agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Get around site's SSL problems

url = 'https://maps.googleapis.com/maps/api/place/textsearch/json?'
File.open('zipCodes.txt','r').readlines[0..-1].each{|zipCode|
	zipCode = zipCode.strip
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
	
	fullUrl = url+getParamsString
	p "OPENING #{fullUrl}"
	resultJSON = agent.get(fullUrl).body
	resultHash = JSON.parse(resultJSON)
	resultsArray = resultHash['results']
	if(resultsArray.length===0)
		next
	end

	resultsArray.each{|result|
		formattedAddress = result['formatted_address']
		formattedAddressArray = formattedAddress.split(', ')
		country = formattedAddressArray[3] # DATAPOINT

		if(country==='United States')
			street = formattedAddressArray[0] # DATAPOINT
			city = formattedAddressArray[1] # DATAPOINT
			stateZipArray = formattedAddressArray[2].split(' ')
			state = stateZipArray[0] # DATAPOINT
			location = result['geometry']['location']
			lat = location['lat'].to_f # DATAPOINT
			lng = location['lng'].to_f # DATAPOINT
			gPlaceId = location['id'] # DATAPOINT
			name = location['name'] # DATAPOINT
		end
	}
}
