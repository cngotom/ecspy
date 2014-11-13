#安装
bundle install


#淘宝爬虫
[phantomjs]: http://phantomjs.org


##爬虫 rake
rake update_shop_item_sales 更新订单
rake update_shop_items_list 更新商品list
rake update_ranks 更新关键字排名

##爬虫调试
###items_list 
in rails root
```
phantomjs  --load-images=no ./lib/tasks/phantomjs-script/getlist.js http://slwsp.tmall.com/ 1 log/phantomjs/getlist.res.2014-11-13-15-00 log/phantomjs/getlist.log
```

###items_sales
```
phantomjs  --load-images=no ./lib/tasks/phantomjs-script/getitem.js 35018792719 1409113824 log/phantomjs/getsales.res log/phantomjs/getsales.log
```


#启动 from centos
##rvm version
rvm use 1.9.3

##start mysql
/etc/init.d/mysqld start

##start merger
RAILS_ENV=production nohup rake merge_daemon > /dev/null &

##start redis
redis-server /etc/redis.conf 

##start resque
resque-web -p 8282

##start rails
thin start -C myapp.yml

##start resque workers
QUEUE=* nohup rake resque_work &`

##start crond(optional)
/etc/init.d/crond start



