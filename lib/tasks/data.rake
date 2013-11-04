#require 'xml/xslt'
require 'spira'
require 'rdf/ntriples'
#require 'rexml/document'
#require 'net/http'
#require 'sparql/client'

desc "Process a large DBPedia N-triples file into a more compact form for the suggester"
task :prepare_articles => :environment do
  fname = ENV['DBP_TRIPLES'] || '/tmp/dbpedia_labels.nt'
  count = 0
  WikipediaLabel.delete_all # truncate the table before import
  articles = []
  IO.foreach(fname) { |line|
    /<http:\/\/dbpedia.org\/resource\/(.*)> <http:\/\/www.w3.org\/2000\/01\/rdf-schema#label> "(.*)"@en/.match(line) {|m|
      subject, object = m[1], m[2]
      articles << WikipediaLabel.new(:uri => subject, :label => object)
      count = count + 1
      if count % 1000 == 0
        WikipediaLabel.import articles
        articles = []
      end
      print "#{count} lines inserted.         \r" if count % 200 == 1
    }
  }
  WikipediaLabel.import articles # final bit
  print "Done importing Wikipedia article labels into lookup table.  #{count} lines inserted.\n"
end

desc "Process the Geonames Cities file"
task :prepare_cities => :environment do
  fname = ENV['GEO_CITIES'] || '/tmp/cities15000.txt'
  count = 0
  GeonameCity.delete_all # truncate before import
  cities = []
  IO.foreach(fname) { |line|
    # Geonames cities TSV order: (from http://download.geonames.org/export/dump/ )
    # geo_id, label, ascii_label, alt_labels, latitude, longitude, feature_class, feature_code, country_code, alt_country_code, admin1, admin2, admin3, admin4, population, elevation, gtopo30, timezone, modification_date
    fields = line.chomp.split /\t/
    cities << GeonameCity.new(:geo_id => fields[0], :label => fields[1], :ascii_label => fields[2], :alt_labels => fields[3], :latitude => fields[4], :longitude => fields[5], :feature_class => fields[6], :feature_code => fields[7], :country_code => fields[8], :alt_country_code => fields[9], :population => fields[14].to_i, :elevation => fields[15].to_i, :timezone => fields[17], :modification_date => fields[18])
    count += 1
    if count % 1000 == 0 # buffer the inserts
      GeonameCity.import cities
      cities = []
    end 
    print "#{count} lines inserted.         \r" if count % 200 == 1
  }
  GeonameCity.import cities # remaining inserts
  print "Done importing Geonames cities file into lookup table. #{count} lines inserted.\n"
end
