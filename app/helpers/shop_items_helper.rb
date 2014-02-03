module ShopItemsHelper

	def versions_of_content(item)

		versions = {}
		item.content.versions.each do |v|
			versions[v.version] = v.version
		end
		versions


	end
end
