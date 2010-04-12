class AddFeedbackTable < ActiveRecord::Migration
  def self.up
    create_table :feedback do |t|
        t.column :file_location, :string, :null => false
        t.column :verb, :string, :null => false
        t.column :from, :string
        t.timestamps
    end
  end

  def self.down
    drop_table :feedback
  end
end
