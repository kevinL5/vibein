var tag = document.createElement('script');

tag.src = "https://www.youtube.com/iframe_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

var player;

function onYouTubeIframeAPIReady() {
  player = new YT.Player('ytplayer', {
    events: {
      'onStateChange': onPlayerStateChange
    }
  });
}

function onPlayerStateChange() {
  console.log(player.getPlayerState());
}

/*

SC.stream("http://api.soundcloud.com/tracks/" + trackId, {
  onfinish: function(){
    console.log('track finished');
  }
},
  function(sound){currentTrack = sound;
  }
);

*/