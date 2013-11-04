class RefactorAnnotationConstraints < ActiveRecord::Migration
  def up
    remove_column :annotation_constraints, :context
    remove_column :annotation_constraints, :checksum
    remove_column :annotation_constraints, :position
    add_column :annotation_constraints, :constraint, :binary
    add_column :annotation_constraints, :constraint_type, :string
  end

  def down
    remove_column :annotation_constraints, :constraint
    remove_column :annotation_constraints, :constraint_type
    add_column :annotation_constraints, :context, :string
    add_column :annotation_constraints, :position, :string
    add_column :annotation_constraints, :checksum, :string
  end
end
