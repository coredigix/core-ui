var reactor;

console.log('---- test watch');

// create reactor instance
reactor = new Reactor();

reactor.watch('.btn.dada', {
  click: function(event) {
    return console.log('---- data cliked: ', this);
  }
});

// mouseover:

console.log('---- define zone');

reactor.watch('.zone', {
  click: function(event) {
    return console.log('---- zone clicked: ', event.target);
  },
  mouseover: function(event) {
    return console.log('---- mouseover:');
  },
  mouseout: function(event) {
    return console.log('---- mouseout:');
  },
  hover: function(event) {
    return console.log('---HOVER');
  },
  hout: function(event) {
    return console.log('---HOUT');
  },
  moveStart: function(event) {
    return console.log(`--->> MOVE starts: (${event.x}, ${event.y}) delta: (${event.dx}, ${event.dy})`);
  },
  moveEnd: function(event) {
    return console.log(`--->> MOVE ends: (${event.x}, ${event.y}) delta: (${event.dx}, ${event.dy})`);
  },
  move: function(event) {
    return console.log(`--->> MOVE: (${event.x}, ${event.y}) delta: (${event.dx}, ${event.dy})`);
  }
});
