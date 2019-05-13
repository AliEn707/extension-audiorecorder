package openfl.extension;


import haxe.Timer.delay;
import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.io.BytesInput;
import lime.utils.UInt8Array;
import lime.media.AudioBuffer;
import com.player03.android6.Permissions;
#if android
import lime.system.JNI;
#elseif !flash
import lime.system.CFFI;
#end



class Audiorecorder {
	
	public static var RECORDER_SAMPLERATE:Int = 0;
	public static var RECORDER_CHANNELS:Int = 0;
	public static var RECORDER_BITS:Int = 0;
	
	public static var sampleRates:Array<Int> = [8000, 11025, 16000, 22050, 44100];
	public static var channels:Array<Int> = [1, 2];
	public static var bits:Array<Int> = [8,16];
	
	private static var _init = new Audiorecorder();
	private function new(){
		#if neko
			cpp.Prime.nekoInit("extension_audiorecorder");
		#end
	}
	
	public static function startRecording(callback:Bytes->Void, ?fail:String->Void, ?ready:Void->Void, size:Int = 0){
		initConfig();
		if (checkPermission(startRecording.bind(callback, fail, ready, size), Permissions.RECORD_AUDIO)){
			var arr = extension_audiorecorder_startRecording(new CallBackAction(callback, fail, ready), size).split(",");
			RECORDER_SAMPLERATE = Std.parseInt(arr[0]);
			RECORDER_CHANNELS = Std.parseInt(arr[1]);
			RECORDER_BITS = Std.parseInt(arr[2]) * 8;
		}	
	}
	
	public static function startRecordingBluetooth(callback:Bytes->Void, ?fail:String->Void, ?ready:Void->Void, size:Int = 0){
		initConfig();
		if (checkPermission(startRecordingBluetooth.bind(callback, fail, ready, size), Permissions.RECORD_AUDIO)){
		extension_audiorecorder_startRecordingBluetooth(new CallBackAction(callback, fail, ready), new CallBackAction(function(arr:Bytes){}, function(str:Dynamic){
				var arr = str.split(",");
				RECORDER_SAMPLERATE = Std.parseInt(arr[0]);
				RECORDER_CHANNELS = Std.parseInt(arr[1]);
				RECORDER_BITS = Std.parseInt(arr[2]) * 8;
			}), size);
		}
	}
	
	public static function stopRecording(){
		extension_audiorecorder_stopRecording();
	}
	
	public static function enableSupressor(mode:Bool):Bool{
		return extension_audiorecorder_enableSupressor(mode);
	};

	public static function isSilent(pcm:Array<Int>, treshhold:Int = 10, ?samplerate:Int, ?bits:Int, ?channels:Int):Bool{
		if (samplerate == null)
			samplerate = RECORDER_SAMPLERATE;
		if (bits == null)
			bits = RECORDER_BITS;
		if (channels == null)
			channels = RECORDER_CHANNELS;
		
		for (i in pcm){
			if (i + 127 > treshhold) //TODO:check values of array
				return false;
		}
		return true;
	}

	public static function isHeadsetEvailable():Bool{		
		return extension_audiorecorder_isHeadsetEvailable();
	}
	
	public static function getAudioBuffer(pcm:Bytes, ?samplerate:Int, ?bits:Int, ?channels:Int):AudioBuffer{
		if (samplerate == null)
			samplerate = RECORDER_SAMPLERATE;
		if (bits == null)
			bits = RECORDER_BITS;
		if (channels == null)
			channels = RECORDER_CHANNELS;
			
		var audioBuffer = new AudioBuffer();
		audioBuffer.bitsPerSample = bits;
		audioBuffer.channels = channels;
		audioBuffer.sampleRate = samplerate;
		audioBuffer.data = UInt8Array.fromBytes(pcm);
		return audioBuffer;
	}

	private static function initConfig(){
	#if android
		extension_audiorecorder_clearRates();
		extension_audiorecorder_clearChannels();
		extension_audiorecorder_clearBits();
		for (i in sampleRates){
			extension_audiorecorder_addRate(i);
		}
		for (i in channels){
			extension_audiorecorder_addChannel(i);
		}
		for (i in bits){
			extension_audiorecorder_addBits(i);
		}
	#end
	}

	private static function checkPermission(action:Void->Void, p:String){
	#if android
		if (!Permissions.hasPermission(p)){
			Permissions.requestPermission(p);
			delay(action, 500);
			return false;
		}
	#end
		return true;
	}	
	
#if android
	
	private static var extension_audiorecorder_startRecording = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "startRecording", "(Lorg/haxe/lime/HaxeObject;I)Ljava/lang/String;");
	private static var extension_audiorecorder_startRecordingBluetooth = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "startRecordingBluetooth", "(Lorg/haxe/lime/HaxeObject;Lorg/haxe/lime/HaxeObject;I)V");
	private static var extension_audiorecorder_stopRecording = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "stopRecording", "()V");
	private static var extension_audiorecorder_enableSupressor = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "enableSupressor", "(Z)Z");
	private static var extension_audiorecorder_addRate = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "addRate", "(I)V");
	private static var extension_audiorecorder_addChannel = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "addChannel", "(I)V");
	private static var extension_audiorecorder_addBits = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "addBits", "(I)V");
	private static var extension_audiorecorder_clearRates = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "clearRates", "()V");
	private static var extension_audiorecorder_clearChannels = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "clearChannels", "()V");
	private static var extension_audiorecorder_clearBits = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "clearBits", "()V");
	private static var extension_audiorecorder_isHeadsetEvailable = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "isHeadsetEvailable", "()Z");

#elseif !flash
	private static var extension_audiorecorder_startRecording = CFFI.load ("extension_audiorecorder", "extension_audiorecorder_startRecording", 2);	
	private static var extension_audiorecorder_startRecordingBluetooth = CFFI.load ("extension_audiorecorder", "extension_audiorecorder_startRecordingBluetooth", 3);	
	private static var extension_audiorecorder_stopRecording = CFFI.load ("extension_audiorecorder", "extension_audiorecorder_stopRecording", 0);	
	private static var extension_audiorecorder_enableSupressor = CFFI.load ("extension_audiorecorder", "extension_audiorecorder_enableSupressor", 1);	
	private static var extension_audiorecorder_addRate = CFFI.load ("extension_audiorecorder", "extension_audiorecorder_addRate", 1);	
	private static var extension_audiorecorder_addChannel = CFFI.load ("extension_audiorecorder", "extension_audiorecorder_addChannel", 1);	
	private static var extension_audiorecorder_addBits = CFFI.load ("extension_audiorecorder", "extension_audiorecorder_addBits", 1);	
	private static var extension_audiorecorder_clearRates = CFFI.load ("extension_audiorecorder", "extension_audiorecorder_clearRates", 0);	
	private static var extension_audiorecorder_clearChannels = CFFI.load ("extension_audiorecorder", "extension_audiorecorder_clearChannels", 0);	
	private static var extension_audiorecorder_clearBits = CFFI.load ("extension_audiorecorder", "extension_audiorecorder_clearBits", 0);	
	private static var extension_audiorecorder_isHeadsetEvailable = CFFI.load ("extension_audiorecorder", "extension_audiorecorder_isHeadsetEvailable", 0);	
#end
	
}

class CallBackAction{
	private var _callback:Null<Bytes->Void>;
	private var _fail:Null<String->Void>;
	private var _ready:Null<Void->Void>;
	
	public function new(c:Bytes->Void, ?f:String->Void, ?r:Void->Void){
		_callback = c;
		_fail = f;
		_ready = r;
	}
#if android
	public function action(a:Array<Int>){
		_callback(getBytes(a));
	}
#elseif flash
	public function action(data:Dynamic){
	}
#else
	public function action(data:Dynamic){
		var bytes = @:privateAccess new Bytes (data.length, data.b);
		_callback(bytes);
	}
#end
	public function fail(a:String){
		if (_fail!=null)
			_fail(a);
	}
	
	public function ready(){
		if (_ready!=null)
			_ready();
	}
	
#if android
	private static function getBytes(pcm:Array<Int>):Bytes{
		return haxe.io.UInt8Array.fromArray(pcm).getData().bytes;
	}
#end

}

