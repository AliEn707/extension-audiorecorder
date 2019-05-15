#include <cstdio>
#include <cstdlib>
#include <chrono>
#include <thread>

#include "Utils.h"


namespace extension_audiorecorder {
	
	bool running=0;
	int rate=0;
	int channel=0;
	int bits=0;
	
	
	char* startRecording(int size, callback_data action, callback_fail fail, callback_ready ready, callback_fail prepared){
		unsigned char *a=new unsigned char[size];
		int length=rate*channel*bits/8;
		char out[20];
		running=1;
		srand(time(0));
		sprintf(out, "%d,%d,%d", rate, channel, bits/8);
		ready();
		prepared(out);
//		while(running){
//			std::this_thread::sleep_for(std::chrono::microseconds(size*1000*1000/length));
//			for (int i=0;i<size;i++){
//				a[i]=rand()%200;
//			}
//			action((void*)a, size);
//		}
		fail("error");
		delete[] a;
		return "0,0,0";
	}
	
	void startRecordingBluetooth(int size, callback_data action, callback_fail fail, callback_ready ready, callback_fail prepared){
		prepared("0,0,0");
		fail("error");
	}
	
	void stopRecording(){
		running=0;
	}
	
	bool enableSupressor(bool mode){
		return 0;
	}
	
	bool isHeadsetEvailable(){
		return 0;
	}
	
	void addRate(int val){
		if (rate==0)
			rate=val;
	}
	
	void addChannel(int val){
		if (channel==0)
			channel=val;
	}
	
	void addBits(int val){
		if (bits==0)
			bits=val;
	}
		
	void clearRates(){
		rate=0;
	}
		
	void clearChannels(){
		channel=0;
	}
	
	void clearBits(){
		bits=0;
	}
}