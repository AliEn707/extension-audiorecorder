package haxe.extension;


import haxe.Timer.delay;
import haxe.io.Bytes;
import lime.utils.UInt8Array;
import lime.media.AudioBuffer;
#if ios
import lime.system.CFFI;
#end
#if android
import lime.system.JNI;
#end

import com.player03.android6.Permissions;

class Audiorecorder {
	
	public static var RECORDER_SAMPLERATE:Int = 0;
	public static var RECORDER_CHANNELS:Int = 0;
	public static var RECORDER_BITS:Int = 0;
	
	public static function startRecording(callback:Array<Int>->Void, ?fail:Dynamic->Void, ?ready:Void->Void, size:Int=0){
	#if android
		if (checkPermission(startRecording.bind(callback, fail, ready, size))){
			var arr = jni_startRecording(new CallBackAction(callback, fail, ready), size).split(",");
			RECORDER_SAMPLERATE = Std.parseInt(arr[0]);
			RECORDER_CHANNELS = Std.parseInt(arr[1]);
			RECORDER_BITS = Std.parseInt(arr[2]) * 8;
		}
	#end
	}
	
	public static function startRecordingBluetooth(callback:Array<Int>->Void, ?fail:Dynamic->Void, ?ready:Void->Void, size:Int = 0){
	#if android
		if (checkPermission(startRecordingBluetooth.bind(callback, fail, ready, size))){
			jni_startRecordingBluetooth(new CallBackAction(callback, fail, ready),new CallBackAction(function(arr:Array<Int>){
				RECORDER_SAMPLERATE = arr[0];
				RECORDER_CHANNELS = arr[1];
				RECORDER_BITS = arr[2]*8;
			}), size);
		}
	#end
	}
	
	public static function stopRecording(){
	#if android
		jni_stopRecording();
	#end
	}
	
	public static function enableSupressor(mode:Bool):Bool{
	#if android
		return jni_enableSupressor(mode);
	#end
	};

	public static function isSilent(pcm:Array<Int>, treshhold:Int = 10):Bool{
		for (i in pcm){
			if (i + 127 > treshhold) //TODO:check values of array
				return false;
		}
		return true;
	}

	public static function getBytes(pcm:Array<Int>):Bytes{
		return haxe.io.UInt8Array.fromArray(pcm).getData().bytes;
	}

	public static function getAudioBuffer(pcm:Bytes):AudioBuffer{
		var audioBuffer = new AudioBuffer();
		audioBuffer.bitsPerSample = RECORDER_BITS;
		audioBuffer.channels = RECORDER_CHANNELS;
		audioBuffer.sampleRate = RECORDER_SAMPLERATE;
		audioBuffer.data = UInt8Array.fromBytes(pcm);
		return audioBuffer;
	}

#if android
	private static function checkPermission(action:Void->Void){
		if (!Permissions.hasPermission(Permissions.RECORD_AUDIO)){
			Permissions.requestPermission(Permissions.RECORD_AUDIO);
			delay(action, 500);
			return false;
		}
		return true;
	}
	
	private static var jni_startRecording = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "startRecording", "(Lorg/haxe/lime/HaxeObject;I)Ljava/lang/String;");
	private static var jni_startRecordingBluetooth = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "startRecordingBluetooth", "(Lorg/haxe/lime/HaxeObject;Lorg/haxe/lime/HaxeObject;I)V");
	private static var jni_stopRecording = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "stopRecording", "()V");
	private static var jni_enableSupressor = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "enableSupressor", "(Z)Z");
#elseif ios
	private static var extension_audiorecorder_sample_method = CFFI.load ("extension_audiorecorder", "extension_audiorecorder_sample_method", 1);	
#end
	
}

class CallBackAction{
	private var _callback:Null<Array<Int>->Void>;
	private var _fail:Null<Dynamic->Void>;
	private var _ready:Null<Void->Void>;
	
	public function new(c:Array<Int>->Void, ?f:Dynamic->Void, ?r:Void->Void){
		_callback = c;
		_fail = f;
		_ready = r;
	}
	
	public function action(a:Array<Int>){
		_callback(a);
	}
	
	public function fail(a:Dynamic){
		if (_fail!=null)
			_fail(a);
	}
	
	public function ready(){
		if (_ready!=null)
			_ready();
	}
}

