class CreateFamilyTrees < ActiveRecord::Migration[7.1]
  def change
    create_table :family_trees do |t|
      t.string :name
      t.text :description
      t.string :privacy_setting, default: 'private'
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
