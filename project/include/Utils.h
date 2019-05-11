#ifndef EXTENSION_AUDIORECORDER_H
#define EXTENSION_AUDIORECORDER_H

#include <hx/CFFI.h>

namespace extension_audiorecorder {
	
	typedef void (callback_data)(void*, int);
	typedef void (callback_ready)();
	typedef void (callback_fail)(char*);
	
	int SampleMethod(int inputValue);
	
	extern "C"	
	char* startRecording(int size, callback_data action, callback_fail fail, callback_ready ready);
	
	extern "C"	
	void startRecordingBluetooth(int size, callback_data action, callback_fail fail, callback_ready ready, callback_fail prepared);
}


#endif