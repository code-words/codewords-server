class AddSubscribedToPlayer < ActiveRecord::Migration[5.2]
  def change
    add_column :players, :subscribed, :boolean, default: false
  end
end
