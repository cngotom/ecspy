module UserCenterHelper

	def link_with_cur(path,title)
		cur = 'cur' if request.path == path
		"<li><a href='#{path}' class='#{cur}'><i class='icon-chevron-right'></i> #{title} </a></li>"
	end
end
