Rabl.configure do |config|
  # Commented as these are the defaults
  # config.json_engine = nil # Any multi\_json engines
  # config.msgpack_engine = nil # Defaults to ::MessagePack
  # config.include_json_root = true
  # config.include_msgpack_root = true
  # config.include_xml_root  = false
  config.enable_json_callbacks = true
  # config.xml_options = { :dasherize  => true, :skip_types => false }
end
