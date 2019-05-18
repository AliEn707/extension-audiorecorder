#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include <cstring>

#include <hx/CFFI.h>
#include <hxcpp.h>
#include <Array.h>


#include "Utils.h"


using namespace extension_audiorecorder;

#define idval(name) id_##name?id_##name:id_##name=val_id(#name)

static value _callback;

static int id_b;
static int id_length;
static int id_action;
static int id_fail;
static int id_ready;
static int id_format;
	
static void onData(void* dataIn, int length){
	value bytes;

	unsigned char* data;

	buffer b = alloc_buffer_len (length);
	data = (unsigned char*)buffer_data (b);
	if (data) {
		bytes = buffer_val (b);
	} else {
		bytes = alloc_raw_string (length);
		data = (unsigned char*)val_string (bytes);
	}
	memcpy(data, dataIn, length);
	
	value object = alloc_empty_object ();
	alloc_field (object, idval(b), bytes);
	alloc_field (object, idval(length), alloc_int (length));
	
	if (_callback)
		val_ocall1(_callback, idval(action), object);
}

static void onFail(char* error){
	if (_callback)
		val_ocall1(_callback, idval(fail), alloc_string(error));
}

static void onReady(){
	if (_callback)
		val_ocall0(_callback, idval(ready));
}

static void onPrepared(char* val){
	if (_callback)
		val_ocall1(_callback, idval(format), alloc_string(val));
}


static value extension_audiorecorder_startRecording(value callback, value vsize){
	_callback=callback;
	startRecording(val_int(vsize), &onData, &onFail, &onReady, &onPrepared);
	return alloc_null();
}
DEFINE_PRIM(extension_audiorecorder_startRecording, 2);

static value extension_audiorecorder_startRecordingBluetooth(value callback, value vsize){
	//do some work
	_callback=callback;
	startRecordingBluetooth(val_int(vsize), &onData, &onFail, &onReady, &onPrepared);
	return alloc_null();
}
DEFINE_PRIM(extension_audiorecorder_startRecordingBluetooth, 2);

static value extension_audiorecorder_stopRecording(){
	//do some work
	stopRecording();
//	_callback=0;
	return alloc_null();
}
DEFINE_PRIM(extension_audiorecorder_stopRecording, 0);

static value extension_audiorecorder_enableSupressor(value mode){
	enableSupressor(val_bool(mode));
	return alloc_bool(0);
}
DEFINE_PRIM(extension_audiorecorder_enableSupressor, 1);

static value extension_audiorecorder_addRate(value val){
	addRate(val_int(val));
	return alloc_null();
}
DEFINE_PRIM(extension_audiorecorder_addRate, 1);

static value extension_audiorecorder_addChannel(value val){
	addChannel(val_int(val));
	return alloc_null();
}
DEFINE_PRIM(extension_audiorecorder_addChannel, 1);

static value extension_audiorecorder_addBits(value val){
	addBits(val_int(val));
	return alloc_null();
}
DEFINE_PRIM(extension_audiorecorder_addBits, 1);

static value extension_audiorecorder_clearRates(){
	clearRates();
	return alloc_null();
}
DEFINE_PRIM(extension_audiorecorder_clearRates, 0);

static value extension_audiorecorder_clearChannels(){
	clearChannels();
	return alloc_null();
}
DEFINE_PRIM(extension_audiorecorder_clearChannels, 0);

static value extension_audiorecorder_clearBits(){
	clearBits();
	return alloc_null();
}
DEFINE_PRIM(extension_audiorecorder_clearBits, 0);

static value extension_audiorecorder_isHeadsetEvailable(){
	return alloc_bool(isHeadsetEvailable());
}
DEFINE_PRIM(extension_audiorecorder_isHeadsetEvailable, 0);


extern "C" void extension_audiorecorder_main () {
	
	val_int(0); // Fix Neko init
	
}
DEFINE_ENTRY_POINT (extension_audiorecorder_main);



extern "C" int extension_audiorecorder_register_prims () { return 0; }