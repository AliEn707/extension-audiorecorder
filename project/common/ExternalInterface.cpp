#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "Utils.h"


using namespace extension_audiorecorder;



static value extension_audiorecorder_sample_method (value inputValue) {
	
	int returnValue = SampleMethod(val_int(inputValue));
	return alloc_int(returnValue);
}
DEFINE_PRIM (extension_audiorecorder_sample_method, 1);


static value extension_audiorecorder_startRecording(value callback, int size){
	//do some work
	return alloc_string("0,0,0");
}
DEFINE_PRIM(extension_audiorecorder_startRecording, 2);

static value extension_audiorecorder_startRecordingBluetooth(value callback, value result, int size){
	//do some work
	return alloc_null();
}
DEFINE_PRIM(extension_audiorecorder_startRecordingBluetooth, 3);

static value extension_audiorecorder_stopRecording(){
	//do some work
	return alloc_null();
}
DEFINE_PRIM(extension_audiorecorder_stopRecording, 0);


extern "C" void extension_audiorecorder_main () {
	
	val_int(0); // Fix Neko init
	
}
DEFINE_ENTRY_POINT (extension_audiorecorder_main);



extern "C" int extension_audiorecorder_register_prims () { return 0; }