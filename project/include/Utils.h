#ifndef EXTENSION_AUDIORECORDER_H
#define EXTENSION_AUDIORECORDER_H

#include <hx/CFFI.h>

namespace extension_audiorecorder {
	
	#ifdef __cplusplus
	extern "C"{
	#endif
	
	typedef void (callback_data)(void*, int);
	typedef void (callback_ready)();
	typedef void (callback_fail)(char*);
	
	char* startRecording(int size, callback_data action, callback_fail fail, callback_ready ready);
	
	void startRecordingBluetooth(int size, callback_data action, callback_fail fail, callback_ready ready, callback_fail prepared);
	
	void stopRecording();
	
	bool isHeadsetEvailable();
	
	bool enableSupressor(bool mode);
	
	void addRate(int val);
	void addChannel(int val);
	void addBits(int val);
	void clearRates();
	void clearChannels();
	void clearBits();
	
	#ifdef __cplusplus
	}
	#endif
}


#endif