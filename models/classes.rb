class Place  < Sequel::Model
	set_dataset :GooglePlaces

	def self.lastZip
		placeObject = self.select(:Zip)
			.reverse_order(:Zip)
			.limit(1)
			.all[0]

		# placeObject will be `nil` if table has now rows
		if(placeObject===nil)
			return nil
		end

		return placeObject.Zip
	end
end