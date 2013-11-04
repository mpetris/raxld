object @annotation
child :annotation_body do
 attribute :uri, :mime_type, :created_at, :updated_at
end
child :annotation_target_instances do
  child :annotation_constraint do
    attribute :constraint, :constraint_type, :created_at, :updated_at
  end
  child :annotation_target_info do
    attribute :uri, :mime_type
  end
end
