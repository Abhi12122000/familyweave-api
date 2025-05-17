# frozen_string_literal: true

class RenameExpiresAtToExpInJwtDenylists < ActiveRecord::Migration[7.1]
  def change
    rename_column :jwt_denylists, :expires_at, :exp
  end
end 