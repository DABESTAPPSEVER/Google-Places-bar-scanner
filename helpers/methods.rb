def errorLogging(e)
	p "ERROR: #{e}"
	puts e.backtrace

	errorLog = 'ERRORS.txt'

	if(File.exist?(errorLog)===false)
		File.open(errorLog,'w')
	end

	File.open(errorLog,'a'){|f|
		[
			'====================',
			Time.now,
			e,
			e.backtrace
		].each{|err| 
			f.puts(err)
		}
	}
end

def devKeyChooser(agent, devKeyArray)
	devKeyArray.each_with_index{|key,idx|
		# Testing if current key is over Google Place's API limit
		testURL = 'https://maps.googleapis.com/maps/api/place/search/json?location=-33.88471,151.218237&radius=100&sensor=true&key='+key
		response = agent.get(testURL).body
		responseHash = JSON.parse(response)
		if(responseHash['status']==='OVER_QUERY_LIMIT')
			if(idx===devKeyArray.length-1)
				return false
			else
				next
			end
		end	

		return key
	}
end


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
			begin
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
			rescue Exception => e
				next
			end


			newPlace = Place.new
			newPlace.ID = gPlaceId
			newPlace.Name = name
			newPlace.Latitude = lat 
			newPlace.Longitude = lng
			newPlace.Street = street
			newPlace.City = city 
			newPlace.State = state 
			newPlace.Zip = zip 
			begin
				newPlace.save_changes
			rescue Exception => e
				p "ERROR INSERTING #{newPlace}",
				"#{e}"
				# "#{e.backtrace.join("\n")}"
				next
			end
			pp newPlace
		end
	}

	nextPageToken = resultHash['next_page_token']
	if(nextPageToken===nil)
		return false
	end

	sleep 2 # Need to sleep a bit before going to next page or else it won't get the results from the next page
	nextPageResultsURL = listingsURL.gsub(/\&pagetoken\=.*/,'')+'&pagetoken='+nextPageToken
	getListings(agent, nextPageResultsURL)
end