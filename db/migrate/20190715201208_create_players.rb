class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :players do |t|
      t.references :user, foreign_key: true
      t.references :game, foreign_key: true
      t.integer :role
      t.integer :team
      t.string :token, null: false

      t.index :token, unique: true

      t.timestamps
    end
  end
end
