# frozen_string_literal: true

class FamilyTreeNodeSerializer
  include JSONAPI::Serializer
  attributes :id, :first_name, :last_name, :gender, :date_of_birth, :date_of_death,
             :is_placeholder, :created_at, :updated_at

  belongs_to :family_tree
  belongs_to :linked_user, serializer: UserSerializer, if: Proc.new { |record| record.linked_user.present? }
end 