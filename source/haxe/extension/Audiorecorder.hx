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
	
	public static var sampleRates:Array<Int> = [8000, 11025, 16000, 22050, 44100];
	public static var channels:Array<Int> = [1, 2];
	public static var bits:Array<Int> = [8,16];
	
	public static function startRecording(callback:Array<Int>->Void, ?fail:Dynamic->Void, ?ready:Void->Void, size:Int = 0){
		initConfig();
	#if android
		if (checkPermission(startRecording.bind(callback, fail, ready, size), Permissions.RECORD_AUDIO)){
			var arr = jni_startRecording(new CallBackAction(callback, fail, ready), size).split(",");
			RECORDER_SAMPLERATE = Std.parseInt(arr[0]);
			RECORDER_CHANNELS = Std.parseInt(arr[1]);
			RECORDER_BITS = Std.parseInt(arr[2]) * 8;
		}
	#end
	}
	
	public static function startRecordingBluetooth(callback:Array<Int>->Void, ?fail:Dynamic->Void, ?ready:Void->Void, size:Int = 0){
		initConfig();
	#if android
		if (checkPermission(startRecordingBluetooth.bind(callback, fail, ready, size), Permissions.RECORD_AUDIO)){
			jni_startRecordingBluetooth(new CallBackAction(callback, fail, ready), new CallBackAction(function(arr:Array<Int>){}, function(str:Dynamic){
				var arr = str.split(",");
				RECORDER_SAMPLERATE = Std.parseInt(arr[0]);
				RECORDER_CHANNELS = Std.parseInt(arr[1]);
				RECORDER_BITS = Std.parseInt(arr[2]) * 8;
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
		return false;
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

	private static function initConfig(){
	#if android
		jni_clearRates();
		jni_clearChanel();
		jni_clearBits();
		for (i in sampleRates){
			jni_addRate(i);
		}
		for (i in channels){
			jni_addChanel(i);
		}
		for (i in bits){
			jni_addBits(i);
		}
	#end
	}

#if android
	private static function checkPermission(action:Void->Void, p:String){
		if (!Permissions.hasPermission(p)){
			Permissions.requestPermission(p);
			delay(action, 500);
			return false;
		}
		return true;
	}	
	
	private static var jni_startRecording = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "startRecording", "(Lorg/haxe/lime/HaxeObject;I)Ljava/lang/String;");
	private static var jni_startRecordingBluetooth = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "startRecordingBluetooth", "(Lorg/haxe/lime/HaxeObject;Lorg/haxe/lime/HaxeObject;I)V");
	private static var jni_stopRecording = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "stopRecording", "()V");
	private static var jni_enableSupressor = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "enableSupressor", "(Z)Z");
	private static var jni_addRate = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "addRate", "(I)V");
	private static var jni_addChanel = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "addChanel", "(I)V");
	private static var jni_addBits = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "addBits", "(I)V");
	private static var jni_clearRates = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "clearRates", "()V");
	private static var jni_clearChanel = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "clearChanel", "()V");
	private static var jni_clearBits = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "clearBits", "()V");
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

