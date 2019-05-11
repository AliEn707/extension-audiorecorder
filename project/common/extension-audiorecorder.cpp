#include "Utils.h"


namespace extension_audiorecorder {
	
	
	int SampleMethod(int inputValue) {
		
		return inputValue * 100;
		
	}
	
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
	}
	
	void stopRecording(){
	}
	
	bool enableSupressor(bool mode){
		return 0;
	}
}