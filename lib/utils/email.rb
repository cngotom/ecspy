module Utils
	module Email


		Email_login_map = {
			#163
			'163.com' => 'http://mail.163.com',
			'vip.163.com' => 'http://vip.163.com',
			'126.com' => 'http://mail.126.com',

			#qq
			'qq.com' => 'http://mail.qq.com',
			'vip.qq.com' => 'http://mail.qq.com',
			'foxmail.com' => 'http://mail.qq.com',


			#GMAIL
			'gmail.com' => 'http://mail.google.com',

			#sohu
			'sohu.com' => 'http://mail.sohu.com',


			'tom.com' => 'http://mail.tom.com',


			'vip.sina.com' => 'http://vip.sina.com',

			'sina.com.cn' => 'http://mail.sina.com.cn',
			'sina.com' => 'http://mail.sina.com.cn',

			'hotmail.com' => 'http://mail.hotmail.com',
		}

	
		def self.get_email_link(email)
			ext = email.split('@')[1]
			ret = Email_login_map[ext]
			ret
		end

	end
end