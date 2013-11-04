class Annotation < ActiveRecord::Base
#  has_one :annotation_body, :dependent => :destroy
  has_one :annotation_body # since we are minting URIs for annotation bodies, we mustn't ever delete them
  #has_and_belongs_to_many :annotation_target_infos
  has_many :annotation_target_instances, :dependent => :destroy
  has_many :targets, :through => :annotation_target_instances, :source => :annotation_target_info

public
  def construct(body, targets)
    self.annotation_body = body
    @targets = []
    targets.each { |t|
      target = AnnotationTargetInfo.find_by_uri(t[:uri])
      if target.nil?
	# this one's new to us -- create it
        target = AnnotationTargetInfo.new(:uri => t[:uri])
      end
      self.targets << target
      target.save
      self.save
      constraint = t[:constraint]
      unless constraint.nil?
        instance = AnnotationTargetInstance.find_by_annotation_id_and_annotation_target_info_id(self.id, target.id)
        c = AnnotationConstraint.new(:constraint => constraint[:constraint], :constraint_type => constraint[:constraint_type])
        instance.annotation_constraint = c
        instance.save!
      end
      target.save!
    }
    body.save!
  end
end
