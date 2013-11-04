require 'xml/xslt'
require 'nokogiri'
require 'rexml/document'
require 'spira'
require 'rdf/ntriples'
require 'net/http'
require 'uri'

class ApplicationController < ActionController::Base
  protect_from_forgery

before_filter :cors_preflight_check
after_filter :cors_set_access_control_headers

# For all responses in this controller, return the CORS access control headers.

def cors_set_access_control_headers
  headers['Access-Control-Allow-Origin'] = '*'
  headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
  headers['Access-Control-Max-Age'] = "1728000"
  headers['Access-Control-Allow-Headers'] = "X-Requested-With,Content-Type,Accept,Origin"
  headers['Access-Control-Expose-Headers'] = "Location"
end

# If this is a preflight OPTIONS request, then short-circuit the
# request, return only the necessary headers and return an empty
# text/plain.

def cors_preflight_check
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version,Accept,Origin'
  if request.method == :options
    headers['Access-Control-Max-Age'] = '1728000'
    render :text => '', :content_type => 'text/plain'
  end
end
def options
  #cors_preflight_check
  head :ok
end
def fetch_url(url, options)
#    r = Net::HTTP.get( URI.parse( url ), options )
  u = URI.parse(url)
  h = Net::HTTP.new(u.host, u.port)
  r = h.get(u.path, options)
  if r.is_a? Net::HTTPSuccess
    r.body
  else
    nil
  end
end
  # this routine ASSUMES the annotation constraints are valid XPaths
  def annotate_xml_and_render_html(xml_uri) # gacked from the old code in texts_controller
    target = AnnotationTargetInfo.find_by_uri(xml_uri) # find annotations for target uri
    unless target.nil? || target.annotations.count == 0
      res = Net::HTTP.get_response(URI.parse(xml_uri))
      if res.code.to_i == 200
        nodes_to_replace = []
        #xmldoc = REXML::Document.new res.body
        xmldoc = Nokogiri::XML(res.body)
        target.annotations.each do |anno|
          c = anno.annotation_target_instances[0].annotation_constraint
          unless c.nil? or c.constraint_type != 'xpath_and_word_count' # only handle properly constrained annotations
            c.constraint.match /,/ # expected format: <xpath>,word-count, e.g. "//TEI.2[1]/p[2],13"
            xpath, word_count = $`, $'.to_i
            node = xmldoc.xpath(xpath).first
            unless node.nil?
              unless anno.annotation_body.nil? or anno.annotation_body.content.nil? or anno.annotation_body.content.empty?
                # prepare the annotation markup
#               anno_body = NokogiriREXML::Element.new('OAC_Annotation')
                anno_body = Nokogiri::XML::Element.new 'OAC_Annotation', xmldoc
                anno_body['class'] = 'OAC_Annotation'
                #anno_body.attributes['class'] = 'OAC_Annotation' # REXML
                if /.jpg$/.match(anno.annotation_body.content)
                  img = Nokogiri::XML::Element.new 'OAC_img', xmldoc
                  #img = REXML::Element.new('OAC_img')
                  img['src'] = anno.annotation_body.content
                  #img.attributes['src'] = anno.body # REXML
                  anno_body.add_child img
                  #anno_body.add img # REXML
                else
                  # assume we just dump the body content as-is in our DIV
                  anno_text = Nokogiri::XML::Text.new anno.annotation_body.content, xmldoc
                  anno_body.add_child(anno_text)
                end
                # serialize existing node and interpolate our annotation markup
                node_as_text = node.serialize
                charpos = find_charpos_by_word_number(node_as_text, word_count, true)
                new_node_text = node_as_text[0..charpos-1] + anno_body.serialize + node_as_text[charpos..-1]
                new_node = Nokogiri::XML(new_node_text).children[0]
                # remember the node to replace and the annotation body to replace it with
                # (we don't do it during the loop to avoid changing the order for later XPath matches)
                nodes_to_replace << [node, new_node]
                #node.parent.insert_after(node, anno_body) # REXML
              end
            end
          end
        end
        nodes_to_replace.each do |n|
          n[0].replace(n[1])
        end

        xslt = XML::XSLT.new()
        xslt.xml = REXML::Document.new xmldoc.serialize # TODO: see about doing this part in Nokogiri as well
        xslt.xsl = REXML::Document.new File.read(::Rails.root.to_s+'/public/'+"min.xsl")
        #xslt.xsl = REXML::Document.new File.read( ::Rails.root.to_s+'/public/'+"tei.xsl")
        xhtml = xslt.serve()
        #temporary, fugly hack
        xhtml.gsub!(/\n/, '<br/>')
        xhtml.gsub!(/<br\/>\s+<br\/>/, '<br/>') # more quick fuglyness to reduce ick
      end
    end
    
    return xhtml
  end

  # Dirk Roorda's word counting code (originally in Perl)
  def find_charpos_by_word_number (text, word_number, with_outermost_tags)
	hot_layer = 0
	if with_outermost_tags then
		hot_layer = 1
	end

	elementstack = Array.new
	wordpos = 0;
	charpos = 0;
	rest = text
	while wordpos < word_number and rest != "" 
		if rest =~ /<[^>]+>/ then
			pre = $`;
			tag = $&;
			rest = $';
		else
			pre = rest
			tag = ""
			rest = ""
		end
		if elementstack.length != hot_layer then
			charpos += pre.length
		else 
			prerep = pre;
			prerep.sub(/^\s+/,'')
			prerep.sub(/\s+$/,'')
			prewords = prerep.split(/\s+/)
			if prewords.length < word_number - wordpos then
				charpos += pre.length;
				wordpos += prewords.length;
			else
				rest = pre;
				while wordpos < word_number and rest != ""
					if rest =~ /^\S+|\s+/
						item = $&
						rest = $'
					else
						item = rest
						rest = ''
					end
					isblank = item =~ /\s/
					if not isblank then
						wordpos += 1
						if wordpos < word_number then
							charpos += item.length
						end
					else
						charpos += item.length
					end
				end
			end
		end
		if wordpos < word_number then
			if tag != "" then
				charpos += tag.length
				tag =~ /^<([!?\/]?)([^\s>]*)/
				close = $1
				name = $2
				if close == "/" then
					elementstack.pop
				elsif close == "" then
					if not (tag =~ /\/\s*>$/) then
						elementstack.push(name)
					end
				end
			end
		end
	end
	charpos
  end
end
