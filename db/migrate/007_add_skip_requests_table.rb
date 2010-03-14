class AddSkipRequestsTable < ActiveRecord::Migration
  def self.up
    create_table :skip_requests do |t|
        t.column :file_location, :string
        t.column :requested_by, :string
        t.timestamps
    end
  end

  def self.down
    drop_table :skip_requests
  end
end
