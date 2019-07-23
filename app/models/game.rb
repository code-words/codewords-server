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

  default_scope { includes(:players, :game_cards) }

  def process_guess(card_id)
    all_cards = self.game_cards.to_a
    cp = self.current_player
    opposing_team = cp.red? ? :blue : :red

    @turn_card = all_cards.find{|card| card.id == card_id}
    @turn_card.update_attribute(:chosen, true)
    self.guesses.create(team: cp.team, game_card: @turn_card)

    # Handle Gameover States
    if @turn_card.assassin?
      @gameover = true
      @winner = opposing_team
      return gameover_response
    else
      player_cards = all_cards.select{|card| card.category == cp.team}
      opposing_cards = all_cards.select{|card| card.category == opposing_team.to_s}
      if player_cards.all?{|card| card.chosen?}
        @gameover = true
        @winner = cp.team
        return gameover_response
      elsif opposing_cards.all?{|card| card.chosen?}
        @gameover = true
        @winner = opposing_team
        return gameover_response
      end
    end

    # Handle Continuing Game
    if card_is_current_team? && self.guesses_remaining > 1
      self.guesses_remaining -= 1
      self.save
      return guess_response
    else
      self.advance!
      return guess_response
    end
  end

  def advance!
    if self.current_player.intel?
      self.current_player = players.where(team: self.current_player.team, role: :spy).first
    else
      self.current_player = players.where.not(team: self.current_player.team).where(role: :intel).first
      self.guesses_remaining = 0
    end
    self.save
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

  def over?
    @gameover || false
  end

  def includes_card?(id)
    card_ids = self.game_cards.pluck :id
    card_ids.include? id
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

      self.current_player = blue_first? ? blue_players.first : red_players.first

      self.save
    end

     ######   ##     ## ########  ######   ######
    ##    ##  ##     ## ##       ##    ## ##    ##
    ##        ##     ## ##       ##       ##
    ##   #### ##     ## ######    ######   ######
    ##    ##  ##     ## ##             ##       ##
    ##    ##  ##     ## ##       ##    ## ##    ##
     ######    #######  ########  ######   ######

    ##     ##    ###    ##    ## ########  ##       #### ##    ##  ######
    ##     ##   ## ##   ###   ## ##     ## ##        ##  ###   ## ##    ##
    ##     ##  ##   ##  ####  ## ##     ## ##        ##  ####  ## ##
    ######### ##     ## ## ## ## ##     ## ##        ##  ## ## ## ##   ####
    ##     ## ######### ##  #### ##     ## ##        ##  ##  #### ##    ##
    ##     ## ##     ## ##   ### ##     ## ##        ##  ##   ### ##    ##
    ##     ## ##     ## ##    ## ########  ######## #### ##    ##  ######

    def card_is_current_team?
      @turn_card.category == self.current_player.team
    end

    def guess_response
      {
        card: @turn_card,
        remainingAttempts: self.guesses_remaining,
        currentPlayer: self.current_player
      }
    end

    def gameover_response
      {
        card: @turn_card,
        winningTeam: @winner
      }
    end
end
