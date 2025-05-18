class FamilyTree < ApplicationRecord
  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'
  has_many :family_tree_nodes, dependent: :destroy

  validates :name, presence: true # Adding a basic validation for name

  # Placeholder for has_many :family_tree_nodes, dependent: :destroy (will be added later)
end
