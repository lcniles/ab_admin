class CreateStaticPages < ActiveRecord::Migration
  def change
    create_table :static_pages do |t|
      t.integer   :structure_id, null: false
      t.references :user
      t.boolean :is_visible, default: true, null: false

      t.timestamps
    end

    add_index :static_pages, :user_id
    add_index :static_pages, :structure_id
  end
end