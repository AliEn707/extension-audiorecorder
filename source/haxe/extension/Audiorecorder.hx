package haxe.extension;


import haxe.io.Bytes;
import lime.utils.UInt8Array;
import lime.media.AudioBuffer;
import lime.system.CFFI;
import lime.system.JNI;


class Audiorecorder {
	
	public static var RECORDER_SAMPLERATE:Int = 0;
	public static var RECORDER_CHANNELS:Int = 0;
	public static var RECORDER_BITS:Int = 0;
	
	public static function startRecording(callback:Array<Int>->Void, ?fail:Dynamic->Void, size:Int=0){
	#if android
		var arr = jni_startRecording(new CallBackAction(callback, fail), size).split(",");
		RECORDER_SAMPLERATE = Std.parseInt(arr[0]);
		RECORDER_CHANNELS = Std.parseInt(arr[1]);
		RECORDER_BITS = Std.parseInt(arr[2])*8;

	#end
	}
	
	public static function startRecordingBluetooth(callback:Array<Int>->Void, ?fail:Dynamic->Void, size:Int = 0){

	}
	
	public static function stopRecording(){
	#if android
		jni_stopRecording();
	#end
	}
	
	public static function enableSupressor(mode:Bool){
	#if android
		jni_enableSupressor();
	#end
	};

	public static function isSilent(pcm:Array<Int>, treshhold:Int=0):Bool{
		return false;
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
	private static var jni_startRecording = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "startRecording", "(Lorg/haxe/lime/HaxeObject;I)Ljava/lang/String;");
	private static var jni_stopRecording = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "stopRecording", "()V");
	private static var jni_enableSupressor = null;// JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "enableSupressor", "(Z)V");
#elseif ios
	private static var extension_audiorecorder_sample_method = CFFI.load ("extension_audiorecorder", "extension_audiorecorder_sample_method", 1);	
#end
	
}

class CallBackAction{
	private var _callback:Array<Int>->Void;
	private var _fail:Null<Dynamic->Void>;
	public function new(c:Array<Int>->Void, ?f:Dynamic->Void){
		_callback = c;
		_fail = f;
	}
	
	public function action(a:Array<Int>){
		_callback(a);
	}
	
	public function fail(a:Dynamic){
		if (_fail!=null)
			_fail(a);
	}
}

