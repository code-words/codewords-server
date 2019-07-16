class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.string :game_key, null: false
      t.string :intel_key, null: false
      t.string :invite_code, null: false

      t.index :game_key, unique: true
      t.index :intel_key, unique: true
      t.index :invite_code, unique: true

      t.timestamps
    end
  end
end
