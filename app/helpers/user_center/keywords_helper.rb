module UserCenter::KeywordsHelper

	def shopids_to_titles(ids,maps)
		ids = ids.split(',')

		res = ''
		ids.each do |id|
			id = id.to_i
			res = res + maps[id] + '&nbsp;' if maps[id]
		end
		res
	end



end
