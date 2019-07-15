class User < ApplicationRecord
  has_many :players
  has_many :games, through: :players

  validates :name, presence: true, uniqueness: true
end
