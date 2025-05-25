class CreateImports < ActiveRecord::Migration[8.0]
  def change
    create_table :imports do |t|
      t.string :status
      t.integer :successes
      t.jsonb :error_list

      t.timestamps
    end
  end
end
