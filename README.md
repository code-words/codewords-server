# Codewords Server [![Build Status](https://travis-ci.com/code-words/codewords-server.svg?branch=dev)](https://travis-ci.com/code-words/codewords-server)

This is the server side of the [Codewords](http://playcodewords.com) game. It manages game state and handles turn logic, however it does not have a built-in front-end. You will also need the Codewords UI available within this organization.

### Requirements

- Ruby 2.6.3
- Rails 5.2.3
- This server

### Setup

<details><summary>Need to set up a Ruby environment? MacOS instructions within.</summary>

_Note: Depending on your existing setup, you may be able to skip one or more of the steps below. If you're not sure whether you have something installed or not, go ahead and run the respective command, and the command-line tools we're using will let you know that you're good to go._
First, we'll install a Ruby environment manager. [rbenv](https://github.com/rbenv/rbenv) gives you very straightforward tools to manage which version of Ruby you use for a particular project.
- `brew install rbenv`
- `rbenv init`
  - This will instruct you to add content to your `~/.bash_profile`. Do so.
- `source ~/.bash_profile`
- `curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-doctor | bash`
  - The above command should report green across the board. If you get anything else, you'll need to search for assistance on the internet.

Now that rbenv is installed, we need to install Ruby. This project uses Ruby 2.6.3, so we'll start there.
- `rbenv install 2.6.3`
  - If you have used `rbenv` to install Ruby before, you will need to set the correct Ruby version for this project.
  - Once you have cloned down this repository, `cd` into the project root.
  - Run `rbenv local 2.6.3`. (This step can be skipped if `rbenv global` reports you're already using `2.6.3`)
  - With Ruby, the package manager we use is called [Bundler](https://github.com/bundler/bundler). Let's be certain you have the right version.
  - Run `gem install bundler -v 2.0.2`

Next, we'll install the [PostgreSQL](https://formulae.brew.sh/formula/postgresql) database.
- `brew install postgresql`

Finally, we'll install [Redis](https://formulae.brew.sh/formula/redis), which is used to manage our Websockets broadcasts
- `brew install redis`
- redis runs as a service in the background. It uses very little resources, so we'll go ahead and start it now.
- `brew services start redis`
- It will need to be active anytime we're running the server, however you can stop it whenever you don't need it with `brew services stop redis`

At this point, we have everything we need for our Rails environment. If you wish, you can also globally install Rails with `gem install rails -v 5.2.3` however Bundler will ensure you have what you need for this project.

</details>

01. Clone this repository and run `bundle install`.
02. Prepare database with `rails db:create`
03. Migrate with `rails db:migrate`
04. Start the server with `rails s`


### Schema

[![Database Schema Diagram](schema.png)](https://dbdiagram.io/d/5d28ffa3ced98361d6dc9ccb)

## API Endpoints

- [Create/Initiate Game](#create-game)
- [Join Existing Game](#join-game)
- [Get Intel Data](#get-intel)

## Websockets Message Events

|From Server                      |From Client              |
|:---:                            |:---:                    |
|[Player Joined](#player-joined)  |                         |
|[Game Started](#game-started)    |                         |
|[Hint Provided](#hint-provided)  |[Hint Sent](#hint-sent)  |
|[Board Update](#board-update)    |[Guess Sent](#guess-sent)|
|[Game Over](#game-over)          |                         |
|[Illegal Action](#illegal-action)|                         |

---

### Create Game

Request that the server create a new Game instance and attach the requesting user as a Player. Because we are not managing persistent users at this time, this endpoint also creates a User record for the requesting user.

##### Request
```http
POST /api/v1/games
```
```js
{
  "name": "Archer"
}
```
|key&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|description|
|:---: |:--- |
|`name`|String: The username that the requesting user would like to use during the game|

##### Successful Response
```http
HTTP/1.1 201 Created
```
```js
{
  "invite_code": "L6J5suAqTsKUAjEXm5swoEUN",
  "id": 0,
  "name": "Archer",
  "token": "uuxHQc7djqQuzWgJxAp5r1vy"
}
```
|key&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|description|
|:---:        |:--- |
|`invite_code`|String: A code which can be shared with other players. They will use this code to join the game.|
|`id`         |Integer: The unique id for the player.|
|`name`       |String: A confirmation that the requested name was indeed assigned to the player.|
|`token`      |String: A token unique to the current player, which can be used to identify them in future requests to the server.|

<details><summary>Failed Responses</summary>

##### Name Omitted
This error occurs if the body of the request does not contain a `name`, or if the `name` is empty.
```http
HTTP/1.1 401 Unauthorized
```
```js
{
  "error": "You must provide a username"
}
```

</details>

---

### Join Game

Request that the server create a new Player instance for the requesting user and attach it to the Game denoted by the invite code.

##### Request
```http
POST /api/v1/games/:invite_code/players
```
```js
{
  "name": "Lana"
}
```
|key&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|description|
|:---:         |:--- |
|`:invite_code`|String: (Within URI) The invite code provided by the person inviting the requesting user to their existing game.|
|`name`        |String: The username that the requesting user would like to use during the game|

##### Successful Response
```http
HTTP/1.1 200 OK
```
```js
{
  "id": 0,
  "name": "Lana",
  "token": "uuxHQc7djqQuzWgJxAp5r1vy"
}
```
|key&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|description|
|:---:  |:--- |
|`id`   |Integer: The unique id for the player.|
|`name` |String: A confirmation that the requested name was indeed assigned to the player.|
|`token`|String: A token unique to the current player, which can be used to identify them in future requests to the server.|

<details><summary>Failed Responses</summary>

##### Name Omitted
This error occurs if the body of the request does not contain a `name`, or if the `name` is empty.
```http
HTTP/1.1 401 Unauthorized
```
```js
{
  "error": "You must provide a username"
}
```

##### Name Already In Use
This error occurs if the `name` requested by the user is already in use by another Player in this game.
```http
HTTP/1.1 401 Unauthorized
```
```js
{
  "error": "That username is already taken"
}
```

##### Invalid Invite Code
This error occurs if the invite code provided by the user does not match a current game.
```http
HTTP/1.1 401 Unauthorized
```
```js
{
  "error": "That invite code is invalid"
}
```

##### Game Is Full
This error occurs if the invite code provided for the user matches a game that does not have room for additional players.
```http
HTTP/1.1 401 Unauthorized
```
```js
{
  "error": "That game is already full"
}
```

</details>

---

### Get Intel

Request the Intel data for a game, allowing the player to see which cards belong to which team, which are bystanders, and which is the assassin. This endpoint requires a valid token belonging to a player with the intel role.

##### Request
```http
GET /api/v1/intel?token=<player_token>
```
|key&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|description|
|:---:  |:--- |
|`token`|String: A valid token belonging to a Player with the Intel role.|

##### Successful Response
```http
HTTP/1.1 200 OK
```
```js
{
  "cards": [
    {
      "id": 0,
      "word": "<card word>",
      "type": "red"
    }, ...
  ]
}
```
|key&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|description|
|:---:         |:--- |
|`cards`       |Array: An **ordered** collection of `card` objects which are part of the game. These cards go onto the board left-to-right, top-to-bottom.|
|`-->card.id`  |Integer: The unique identifier for the card.|
|`-->card.word`|String: The word for the card.|
|`-->card.type`|String: The type of card to render in the UI: "red", "blue", "bystander", or "assassin".|

<details><summary>Failed Responses</summary>

##### Token Omitted
This error occurs if the querystring of the request does not contain a `token`, or if the `token` is empty.
```http
HTTP/1.1 401 Unauthorized
```
```js
{
  "error": "You must provide your access token"
}
```

##### Invalid Token Code
This error occurs if the provided token does not match a player.
```http
HTTP/1.1 401 Unauthorized
```
```js
{
  "error": "Unable to find a user with that token"
}
```

##### Player Does Not Have Intel Role
This error occurs if the token matches a player who does not have the Intel role for the game.
```http
HTTP/1.1 401 Unauthorized
```
```js
{
  "error": "You are not authorized for this game's secret intel"
}
```

</details>

---

### Player Joined

This message is broadcast to the game channel whenever a player joins the game. It contains the name, ID, team, and role of the player who joined, as well as a roster of all players currently in the game.

##### Payload

```js
{
  type: "player-joined",
  data: {
    id: 0,
    name: "name",
    isBlueTeam: true,
    isIntel: true,
    playerRoster: [
      {
        id: 0,
        name: "name",
        isBlueTeam: true,
        isIntel: true,
      },
      ...
    ]
  }
}
```

|key&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|Description|
|:---               |:--- |
|`type`             |String: The type of message being broadcast.|
|`data`             |Object: The data payload of the message.|
|`data.id`          |Integer: The unique id of the player who joined.|
|`data.name`        |String: The name of the player who joined.|
|`data.isBlueTeam`  |Boolean: `null` if the player has not been assigned a team, `true` if the player is on the blue team, `false` if they're on the red team.|
|`data.isIntel`     |Boolean: `null` if the player has not been assigned a role, `true` if the player has the Intel role, `false` if they have the Spy role.|
|`data.playerRoster`|Array: A collection of `player` objects for all players currently in the game, **ordered by** the time they joined the lobby.|
|`-->player.id`     |Integer: The unique id of the given player.|
|`-->player.name`   |String: The name of the given player.|
|`-->player.isBlueTeam`|Boolean: `null` if the player has not been assigned a team, `true` if the player is on the blue team, `false` if they're on the red team.|
|`-->player.isIntel`   |Boolean: `null` if the player has not been assigned a role, `true` if the player has the Intel role, `false` if they have the Spy role.|

---

### Game Started

This message is broadcast to the game channel once the final player has joined the lobby. It is broadcast _after_ the [player joined](#player-joined) message generated by that player.

##### Payload

```js
{
  type: "game-setup",
  data: {
    cards: [
      {
        id: 0,
        word: "someword"
      },
      ...
    ],
    players: [
      {
        id: 0,
        name: "name",
        isBlueTeam: true,
        isIntel: true
      },
      ...
    ],
    firstTeam: "red"
  }
}
```

|key&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|description|
|:---                  |:--- |
|`type`                |String: The type of message being broadcast.|
|`data`                |Object: The data payload of the message.|
|`data.cards`          |Array: An **ordered** collection of `card` objects that will be used in the game. These cards go onto the board left-to-right, top-to-bottom.|
|`-->card.id`          |Integer: The unique id for the given card.|
|`-->card.word`        |String: The word to display on a given card.|
|`data.players`        |Array: A collection of `player` objects for all players in the game, **ordered by** the time they joined the lobby.|
|`-->player.id`        |Integer: The unique id for the given player.|
|`-->player.name`      |String: The name for the given player.|
|`-->player.isBlueTeam`|Boolean: `true` if the player is on the blue team, `false` if they're on the red team.|
|`-->player.isIntel`   |Boolean: `true` if the player has the Intel role, `false` if they don't.|
|`data.firstTeam`      |String: The team that will play first: "red" or "blue".|

---

### Hint Sent

This message is sent from the game client to the server by the current player. So long as the sender is the current player and has the Intel role, and the hint is a single-word string, this will generate a [Hint Provided](#hint-provided) broadcast to all players. If any of these requirements are not met, the appropriate [Illegal Action](#illegal-action) message will be broadcast instead.

##### Call

```js
cable.sendHint({
  hintWord: "tree",
  numCards: "3"
})
```

|key&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|Description|
|:---      |:--- |
|`hintWord`|String: A single word hint.|
|`numCards`|Integer: The number of cards to which the hint is related.|

---

### Hint Provided

This message is broadcast to all players after a valid [Hint Sent](#hint-sent) action is performed by a player. After receiving this message, play will proceed to the Spy player on the same team. The Spy will be allowed one more guess than the number of related cards.

##### Payload

```js
{
  type: 'hint-provided',
  data: {
    isBlueTeam: true,
    hintWord: "tree",
    relatedCards: 3,
    currentPlayerId: 1
  }
}
```

|key&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|Description|
|:---                  |:--- |
|`type`                |String: The type of message being broadcast.|
|`data`                |Object: The data payload of the message.|
|`data.isBlueTeam`     |Boolean: Whether the hint belongs to the Blue team or not.|
|`data.hintWord`       |String: The hint word provided by the player.|
|`data.relatedCards`   |Integer: The number of cards this hint is related to.|
|`data.currentPlayerId`|Integer: The ID of the new current player.|


---

### Guess Sent

This message is sent from the game client to the server by the current player. So long as the sender is the current player and has the Spy role, and the provided ID matches a card in the current game, this will generate a [Board Update](#board-update) broadcast to all players, unless the guess causes the game to end, in which case the [Game Over](#game-over) message will be broadcast instead. If any of these requirements are not met, the appropriate [Illegal Action](#illegal-action) message will be broadcast instead.

If the Spy elects not to use all their guesses, they may pass. To convey a pass to the server, this message should be sent with `id: null`.

##### Call

```js
cable.sendGuess({
  id: "1"
})
```

|key&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|Description|
|:--- |:--- |
|`id` |Integer: The ID of the guessed card, or `null` if player ends their guesses early.|

---

### Board Update

This message is broadcast to all players after a valid [Guess Sent](#guess-sent) action is performed by a player, unless the guess causes the game to end (in which case, the [Game Over](#game-over) message will be broadcast instead). After receiving this message, play will proceed to the `currentPlayer` provided in the response.

In the event that a Spy player decides to end their turn without taking all allowed guesses, the returned `card` will be `null` instead of an Object.

##### Payload

```js
{
  type: 'board-update',
  data: {
    card: { // {} or null
      id: 1,
      flipped: true,
      type: "red"
    },
    remainingAttempts: 2,
    currentPlayerId: 1
  }
}
```

|key&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|Description|
|:---                    |:--- |
|`type`                  |String: The type of message being broadcast.|
|`data`                  |Object: The data payload of the message.|
|`data.card`             |Object: Data about the card that was guessed, or `null` if the player has ended their turn without making all allowed guesses.|
|`-->card.id`            |Integer: The ID of the guessed card.|
|`-->card.flipped`       |Boolean: The flipped state of the card (always `true`).|
|`-->card.type`          |String: The type of card to render in the UI: "red", "blue", "bystander", or "assassin".|
|`data.remainingAttempts`|Integer: The number of guesses remaining.|
|`data.currentPlayerId`  |Integer: The ID of the current player.|

---

### Game Over

This message is broadcast to all players after a valid [Guess Sent](#guess-sent) action causes the game to end. After receiving this message, the game UI will render the end state.

##### Payload

```js
{
  type: 'game-over',
  data: {
    card: {
      id: 1,
      flipped: true,
      type: "red"
    },
    winningTeam: "red",
    nextGame: "<invite code>"
  }
}
```

|key&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|Description|
|:---              |:--- |
|`type`            |String: The type of message being broadcast.|
|`data`            |Object: The data payload of the message.|
|`data.card`       |Object: Data about the card that was guessed.|
|`-->card.id`      |Integer: The ID of the guessed card.|
|`-->card.flipped` |Boolean: The flipped state of the card (always `true`).|
|`-->card.type`    |String: The type of card to render in the UI: "red", "blue", "bystander", or "assassin".|
|`data.winningTeam`|String: The team that won the game.|
|`data.nextGame`   |String: An invite code for a new game. Provided automatically so all players can easily join the next game.|

---

### Illegal Action

This message is broadcast to all players after any illegal action is performed by a player in a [Hint Sent](#hint-sent) or [Game Sent](#guess-sent) action.

##### Payload

```js
{
  type: 'illegal-action',
  data: {
    error: "<descriptive message>",
    byPlayerId: 1
  }
}
```

|key&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|Description|
|:---             |:--- |
|`type`           |String: The type of message being broadcast.|
|`data`           |Object: The data payload of the message.|
|`data.error`     |String: The descriptive error message.|
|`data.byPlayerId`|Integer: The ID of the player who performed the illegal action.|

<details><summary>The potential illegal actions that are anticipated and caught are:</summary>

- The player performing the action is not the current player
  - "\<player name\> attempted to submit a (hint/guess) out of turn"
- The player performed an action during their turn, but does not have the correct role for that action
  - "\<player name\> attempted to submit a (hint/guess), but does't have the (Intel/Spy) role"
- An Intel player submits a multi-word hint during their turn
  - "\<player name\> attempted to submit an invalid hint"
- A Spy player submits a guess with a card ID not present in this game
  - "\<player name\> attempted to submit a guess for a card not in this game"

</details>
