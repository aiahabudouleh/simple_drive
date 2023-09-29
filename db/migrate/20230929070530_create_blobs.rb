class CreateBlobs < ActiveRecord::Migration[7.0]
  def change
    create_table :blobs do |t|
      t.string :name
      t.string :uuid
      t.string :storage_type
      t.string :size
      t.string :created_by

      t.timestamps
    end
    add_index :blobs, :uuid, unique: true
  end
end
