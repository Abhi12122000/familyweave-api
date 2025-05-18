# app/serializers/user_serializer.rb
class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :username, :first_name, :last_name,
             :date_of_birth, :gender, :profile_picture_url,
             :cover_photo_url, :current_city, :bio, :relationship_status
end 