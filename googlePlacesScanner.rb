[
	'mechanize',
	'json',
	'sequel',
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

lastZip = Place.lastZip # In case of a crash, get the last known zip code scanned so the script starts from there, as we'll see in the zipCode loop below...

startingFromLastZip = false


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
	
	if(lastZip===nil || lastZip===zipCode)
		startingFromLastZip = true
	end

	if(startingFromLastZip===false)
		# p "SKIPPING ZIP CODE #{zipCode}"
		next
	end

	googleDevKeyArray = ENV['GOOGLE_DEV_KEYS'].split(',')
	key = devKeyChooser(agent, googleDevKeyArray)
	if(key===false)
		p "ALL KEYS OVER LIMIT. SLEEPING FOR ONE HOUR. TIME NOW IS #{Time.now}."
		sleep 3600
	end

	getParamsHash = {
		'query'=>'*+in+'+zipCode,
		'key'=>key,
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
