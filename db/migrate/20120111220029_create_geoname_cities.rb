class CreateGeonameCities < ActiveRecord::Migration
  def change
    create_table :geoname_cities do |t|
      t.string :geo_id
      t.string :label
      t.string :alt_labels
      t.string :latitude
      t.string :longitude
      t.string :feature_class
      t.string :feature_code
      t.string :country_code
      t.string :alt_country_code
      t.integer :population
      t.integer :elevation
      t.string :timezone
      t.string :modification_date

      t.timestamps
    end
  end
end
