App.game_data = App.cable.subscriptions.create("GameDataChannel", {
  connected: function() {
    // Called when the subscription is ready for use on the server
  },

  disconnected: function() {
    // Called when the subscription has been terminated by the server
  },

  received: function(data) {
    // Called when there's incoming data on the websocket for this channel
    targetElm = document.querySelector('#game')
    targetElm.innerHTML = data
    console.log('Received Game Data')
    console.dir(data)
  }
});
