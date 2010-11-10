class AddAdditionalDetailstoContract < ActiveRecord::Migration
  def self.up
    add_column :contracts, :contracting_office, :string
    add_column :contracts, :funding_office, :string
    add_column :contracts, :product_or_service, :string
  end

  def self.down
    remove_column :contracts, :contracting_office
    remove_column :contracts, :funding_office
    remove_column :contracts, :product_or_service
  end
end
