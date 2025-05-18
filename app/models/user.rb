class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  # Validations for core user attributes
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 3, maximum: 30 }
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }

  # Association for FamilyTree ownership
  has_one :owned_family_tree, class_name: 'FamilyTree', foreign_key: 'user_id', dependent: :destroy

  # Association for FamilyTreeNodes linked to this user
  has_many :family_tree_nodes_as_linked_user, class_name: 'FamilyTreeNode', foreign_key: 'linked_user_id', dependent: :nullify

  # If you have other associations or methods, they would go here or below.
end
