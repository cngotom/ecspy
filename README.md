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


centos 重启
/etc/init.d/mysqld start mysql启动
RAILS_ENV=production nohup rake merge_daemon > /dev/null &

redis-server /etc/redis.conf 
resque-web -p 8282
thin start -C myapp.yml

 /etc/init.d/crond start

QUEUE=*  rake resque_work
QUEUE=* nohup rake resque_work &`
