# frozen_string_literal: true

class FamilyTreeSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :description, :privacy_setting, :created_at, :updated_at

  belongs_to :owner, serializer: UserSerializer, id_method_name: :user_id # Specify id_method_name
  # has_many :family_tree_nodes # Add if you want to sideload/include nodes by default
end 