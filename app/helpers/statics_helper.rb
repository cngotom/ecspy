module StaticsHelper


	def calc_sales_count_and_money(sales)
		sale_count = 0
	    sale_money = 0
	    sales.each do |sale|
	       sale_count += 1
	       sale_money += sale.item_num.to_i* sale.item_price.to_f
	    end
	    [sale_count,sale_money.round(2)]
	end



	def get_compare_rate(sale1,sale2)

		increase_count = 1
		increase_money = 1
		count_rate = 0
		money_rate = 0

		#calc count rate
		if sale2[0] == 0
			count_rate = -1  
		else
			count_rate = (sale1[0] - sale2[0])/sale2[0].to_f*100
			if count_rate < 0 
				increase_count = 0
				count_rate = -count_rate
			end

		end

		#calc money rate
		if sale2[1] == 0
			money_rate = -1 
		else
			money_rate = (sale1[1] - sale2[1])/sale2[1].to_f*100

			if money_rate < 0 
				increase_money = 0
				money_rate = -money_rate
			end

		end



		[count_rate.round(2),money_rate.round(2),increase_count,increase_money]
	end


end