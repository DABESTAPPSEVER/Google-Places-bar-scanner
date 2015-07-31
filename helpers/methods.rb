def getListings(agent, listingsURL)
	p "OPENING #{listingsURL}"
	resultJSON = agent.get(listingsURL).body
	resultHash = JSON.parse(resultJSON)
	resultsArray = resultHash['results']
	if(resultsArray.length===0)
		p "NO RESULTS"
		return false
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
			zip = stateZipArray[1].strip # DATAPOINT
			location = result['geometry']['location']
			lat = location['lat'].to_f # DATAPOINT
			lng = location['lng'].to_f # DATAPOINT
			gPlaceId = result['id'] # DATAPOINT
			name = result['name'] # DATAPOINT
			pp result,
			[
				street,
				city,
				state,
				zip,
				lat,
				lng,
				gPlaceId,
				name
			],
			'==============='
		end
	}

	nextPageToken = resultHash['next_page_token']
	if(nextPageToken===nil)
		return false
	end

	nextPageResultsURL = listingsURL+'&pagetoken='+nextPageToken
	getListings(agent, nextPageResultsURL)
end