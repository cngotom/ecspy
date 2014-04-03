require 'pusher'

Pusher.app_id = '70721'
Pusher.key = 'dead170cf3df76678bc5'
Pusher.secret = '09d9f3242c8449968a68'


Pusher.trigger('my-channel', 'my-event', {:message => 'hello world'})