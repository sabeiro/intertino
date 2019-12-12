const {Howl, Howler} = require('howler');
process.exit()

var sound = new Howl({
  src: ['sound.mp3']
});

sound.play();


var sound = new Howl({
  src: ['sound.webm', 'sound.mp3', 'sound.wav'],
  autoplay: true,
  loop: true,
  volume: 0.5,
  onend: function() {
    console.log('Finished!');
  }
});
