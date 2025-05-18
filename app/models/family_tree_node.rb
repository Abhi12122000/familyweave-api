class FamilyTreeNode < ApplicationRecord
  belongs_to :family_tree
  belongs_to :linked_user, class_name: 'User', foreign_key: 'linked_user_id', optional: true

  validates :first_name, presence: true
  # family_tree_id is validated by belongs_to
end
