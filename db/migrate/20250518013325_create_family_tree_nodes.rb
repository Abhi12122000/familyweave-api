class CreateFamilyTreeNodes < ActiveRecord::Migration[7.1]
  def change
    create_table :family_tree_nodes do |t|
      t.references :family_tree, null: false, foreign_key: true
      t.references :linked_user, null: true, foreign_key: { to_table: :users }
      t.string :first_name, null: false
      t.string :last_name
      t.string :gender
      t.date :date_of_birth
      t.date :date_of_death
      t.boolean :is_placeholder, default: true

      t.timestamps
    end
  end
end
