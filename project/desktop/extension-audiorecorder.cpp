#include "Utils.h"


namespace extension_audiorecorder {
	
	char* startRecording(int size, callback_data action, callback_fail fail, callback_ready ready){
		char a[10];
		a[0]=10;
		a[1]=22;
		ready();
		action((void*)a, 2);
		fail("error");
		return "0,0,0";
	}
	
	void startRecordingBluetooth(int size, callback_data action, callback_fail fail, callback_ready ready, callback_fail prepared){
		prepared("0,0,0");
		fail("error");
	}
	
	void stopRecording(){
	}
	
	bool enableSupressor(bool mode){
		return 0;
	}
	
	bool isHeadsetEvailable(){
		return 0;
	}
	
	void addRate(int val){
	}
	
	void addChannel(int val){
	}
	
	void addBits(int val){
	}
		
	void clearRates(){
	}
		
	void clearChannels(){
	}
	
	void clearBits(){
	}
	
}