App.intel_data = App.cable.subscriptions.create("IntelDataChannel", {
  connected: function() {
    // Called when the subscription is ready for use on the server
  },

  disconnected: function() {
    // Called when the subscription has been terminated by the server
  },

  received: function(data) {
    // Called when there's incoming data on the websocket for this channel
    targetElm = document.querySelector('#intel')
    targetElm.innerHTML = data
    console.log('Received Intel Data')
    console.dir(data)
  }
});
