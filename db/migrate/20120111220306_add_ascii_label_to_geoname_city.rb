class AddAsciiLabelToGeonameCity < ActiveRecord::Migration
  def change
    add_column :geoname_cities, :ascii_label, :string
  end
end
