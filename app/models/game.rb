class Game < ApplicationRecord
  has_many :players
  has_many :users, through: :players
  belongs_to :current_player, class_name: "Player", optional: true

  has_many :game_cards
  has_many :cards, through: :game_cards

  has_many :hints
  has_many :guesses

  has_secure_token :invite_code

  accepts_nested_attributes_for :game_cards, :players

  default_scope { includes(:players, :game_cards, :current_player) }

  def advance!
    if current_player.intel?
      current_player = players.where(team: current_player.team, role: :spy).first
    else
      current_player = players.where.not(team: current_player.team).where(role: :intel).first
    end
  end

  def hint_invalid?(hint)
    !hint.match?(/^\w+$/)
  end

  def establish!
    prepare_cards
    prepare_players
  end

  def username_taken? name
    users.any? do |user|
      user.name == name
    end
  end

  def full?
    users.size > 3
  end

  private

     ######      ###    ##     ## ########
    ##    ##    ## ##   ###   ### ##
    ##         ##   ##  #### #### ##
    ##   #### ##     ## ## ### ## ######
    ##    ##  ######### ##     ## ##
    ##    ##  ##     ## ##     ## ##
     ######   ##     ## ##     ## ########

     ######  ######## ######## ##     ## ########
    ##    ## ##          ##    ##     ## ##     ##
    ##       ##          ##    ##     ## ##     ##
     ######  ######      ##    ##     ## ########
          ## ##          ##    ##     ## ##
    ##    ## ##          ##    ##     ## ##
     ######  ########    ##     #######  ##

    def coin_flip
      @_coin_flip ||= Random.rand(0..1)
    end

    def blue_first?
      coin_flip > 0
    end

    def blue_cards
      amt = blue_first? ? 9 : 8
      @_blue_cards ||= @selected_cards.sample(amt).map do |card|
        @selected_cards.delete(card)
        GameCard.new(game: self, card: card, chosen: false, category: :blue)
      end
    end

    def red_cards
      amt = blue_first? ? 8 : 9
      @_red_cards ||= @selected_cards.sample(amt).map do |card|
        @selected_cards.delete(card)
        GameCard.new(game: self, card: card, chosen: false, category: :red)
      end
    end

    def assassin_card
      @_assassin_card ||= begin
        card = @selected_cards.sample(1)[0]
        @selected_cards.delete(card)
        [GameCard.new(game: self, card: card, chosen: false, category: :assassin)]
      end
    end

    def bystander_cards
      @_bystander_cards ||= @selected_cards.map do |card|
        GameCard.new(game: self, card: card, chosen: false, category: :bystander)
      end
    end

    def prepare_cards
      @selected_cards = Card.limit(25).order(Arel.sql("RANDOM()")).to_a

      prepared_cards = blue_cards + red_cards + assassin_card + bystander_cards
      prepared_cards.shuffle!

      prepared_cards.each.with_index do |card, i|
        card.address = i
      end

      GameCard.import prepared_cards
    end

    def prepare_players
      all_players = players.to_a.shuffle
      red_players = all_players.sample(2)
      blue_players = all_players - red_players

      red_players.each.with_index do |player, i|
        player.role = (i == 0) ? :intel : :spy
        player.team = :red
      end

      blue_players.each.with_index do |player, i|
        player.role = (i == 0) ? :intel : :spy
        player.team = :blue
      end

      current_player = blue_first? ? blue_players.first : red_players.first

      self.save
    end
end
