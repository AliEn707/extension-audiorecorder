required android6permissions
if haxelib version doesn't work get it from git https://github.com/AliEn707/android6permissions


Extension for recording audio.


Planned android, ios, desktop(openAL), but ready only android.


If you iterested in this lib or other targets you can fork and pull updates.


##Example

```haxe
delay(function(){Audiorecorder.stopRecording(); }, 10000);

/*
android itarates over Audiorecorder.sampleRates, Audiorecorder.channels and Audiorecorder.bits, and use first available on device.
So you can set needed sequence of params.
Audiorecorder.sampleRates = [8000, 11025, 16000, 22050, 44100]; //or [44100, 22050, 16000];
Audiorecorder.channels = [1, 2];
Audiorecorder.bits = [8,16];
*/

Audiorecorder.startRecording(function(a:Array<Int>){
	var sound:Sound = Sound.fromAudioBuffer(Audiorecorder.getAudioBuffer(Audiorecorder.getBytes(a)));
	sound.play(0, 0);//play recorder sound
},function(e:Dynamic){
	trace(e);
}, function(){
	trace("ready");
},2000);
```