package haxe.extension;


import lime.system.CFFI;
import lime.system.JNI;


class Audiorecorder {
	
	
	public static function sampleMethod (inputValue:Int,c:Dynamic->Void):Void {
		
		#if android
		var a = new CallBackAction(c);
		extension_audiorecorder_sample_method_jni(inputValue, a);
		
		#else
		
		extension_audiorecorder_sample_method(inputValue);
		
		#end
		
	}
	
	public static function startRecording(c:Array<Int>->Void):String{
		return jni_startRecording(new CallBackAction(c));
	}
	
	public static function stopRecording(){
		jni_stopRecording();
	}
	
	#if ios
	private static var extension_audiorecorder_sample_method = CFFI.load ("extension_audiorecorder", "extension_audiorecorder_sample_method", 1);
	
	#elseif android
	private static var extension_audiorecorder_sample_method_jni = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "sampleMethod", "(ILorg/haxe/lime/HaxeObject;)V");
	private static var jni_startRecording = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "startRecording", "(Lorg/haxe/lime/HaxeObject;)Ljava/lang/String;");
	private static var jni_stopRecording = JNI.createStaticMethod ("org.haxe.extension.Audiorecorder", "stopRecording", "()V");
	#end
	
	
}

class CallBackAction{
	private var _callback:Array<Int>->Void;
	public function new(c:Array<Int>->Void){
		_callback = c;
	}
	
	public function action(a:Array<Int>){
		_callback(a);
	}
}

