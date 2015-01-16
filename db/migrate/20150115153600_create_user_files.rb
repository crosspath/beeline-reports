class CreateUserFiles < ActiveRecord::Migration
  def change
    create_table :user_files do |t|
      # t.string :filename
      t.string :original_filename
      t.references :subscriber
      t.date :start_date
      t.date :end_date

      t.timestamps null: false
    end
  end
end
