document.addEventListener("DOMContentLoaded", function(event) {
  var socket = Whistle.sockets()[0];
  var main = socket.getProgram("main");

  main.addHook(".message", {
    creatingElement: function(node) {
      var messages = node.parentNode;
      messages.scrollTop = messages.scrollHeight;
    }
  });
});
