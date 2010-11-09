class CreateContracts < ActiveRecord::Migration
  def self.up
    create_table :contracts do |t|
      t.string :piid
      t.string :agency
      t.string :vendor
      t.integer :industry
      t.float :price
      t.float :footprint
      t.timestamps
    end
  end

  def self.down
    drop_table :contracts
  end
end
