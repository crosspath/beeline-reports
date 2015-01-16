class CreateCalls < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.references :subscriber
      t.datetime :call_date
      t.time :length
      t.integer :length_r
      t.float :cost
      t.string :caller
      t.string :receiver
      t.string :action
      t.string :service
      t.string :service_type
      t.float :volume

      t.timestamps null: false
    end
  end
end
