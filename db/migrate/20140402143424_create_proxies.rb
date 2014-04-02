class CreateProxies < ActiveRecord::Migration
  def change
    create_table :proxies do |t|
      t.string  :addr
      t.float :timeout
      t.datetime :use_time
      t.timestamps
    end
  end
end
