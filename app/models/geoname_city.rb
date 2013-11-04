class GeonameCity < ActiveRecord::Base
  @@cities = GeonameCity.find(:all, :select => :label).map(&:label) # pre-load entire list to memory at load time

  # in-memory boolean lookup function; if it returns true, caller is expected
  # to use activerecord methods to find the actual record, 
  # e.g. GeonameCity.find(:first, :conditions => "label = #{t}")
  def self.lookup(name)
    return @@cities.include?(name)
  end
end
