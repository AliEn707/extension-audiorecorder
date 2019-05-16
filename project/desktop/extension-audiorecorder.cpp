#include <cstdio>
#include <cstdlib>
#include <chrono>
#include <thread>
#include <atomic>
#include <math.h>

#include "Utils.h"

#define PI 3.14159265359

static inline int max(int a,int b) {
	return a>b?a:b;
}


namespace extension_audiorecorder {
	
	static int channels=0;
	static int rate=0;
	static int bits=0;
	static std::atomic_char recording;
	
	void startRecording(int size, callback_data action, callback_fail fail, callback_ready ready, callback_fail prepared){
		unsigned char* a=new unsigned char[size];
		char f[20];
		sprintf(f,"%d,%d,%d",rate,channels,bits/8);
		prepared(f);
		if (channels*bits*rate){
			recording.store(1);
			ready();
			float x=1000.0/channels/bits/rate;
			int j_=rand()%4;
			int hz[4]={rand()%10000,rand()%10000,rand()%10000,rand()%10000};
			while(recording.load()){
				std::this_thread::sleep_for(std::chrono::milliseconds((int)(size*x)));
				for(int i=0;i<size;i++)
					a[i]=0;
				for (int j=0;j<j_;j++){
					for(int i=0;i<size;i++)
						a[i]=max(a[i],150*sin(2*PI*hz[j]*x*i));//rand()%200;
				}
				action((void*)a, size);
			}
		}
		fail("error");
		delete[] a;
	}
	
	void startRecordingBluetooth(int size, callback_data action, callback_fail fail, callback_ready ready, callback_fail prepared){
		prepared("0,0,0");
		fail("error");
	}
	
	void stopRecording(){
		recording.store(0);
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
		if (channels==0)
			channels=val;
	}
	
	void addBits(int val){
		if (bits==0)
			bits=val;
	}
		
	void clearRates(){
		rate=0;
	}
		
	void clearChannels(){
		channels=0;
	}
	
	void clearBits(){
		bits=0;
	}
}