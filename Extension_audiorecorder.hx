package;


import lime.system.CFFI;
import lime.system.JNI;


class Extension_audiorecorder {
	
	
	public static function sampleMethod (inputValue:Int):Int {
		
		#if android
		
		var resultJNI = extension_audiorecorder_sample_method_jni(inputValue);
		var resultNative = extension_audiorecorder_sample_method(inputValue);
		
		if (resultJNI != resultNative) {
			
			throw "Fuzzy math!";
			
		}
		
		return resultNative;
		
		#else
		
		return extension_audiorecorder_sample_method(inputValue);
		
		#end
		
	}
	
	
	private static var extension_audiorecorder_sample_method = CFFI.load ("extension_audiorecorder", "extension_audiorecorder_sample_method", 1);
	
	#if android
	private static var extension_audiorecorder_sample_method_jni = JNI.createStaticMethod ("org.haxe.extension.Extension_audiorecorder", "sampleMethod", "(I)I");
	#end
	
	
}