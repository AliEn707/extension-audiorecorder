package org.haxe.extension;


import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetManager;
import android.content.Context;
import android.content.Intent;
import android.content.BroadcastReceiver;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.media.AudioRecord;
import android.media.AudioFormat;
import android.media.MediaRecorder;
import android.media.AudioManager;
import android.util.Log;
import android.media.audiofx.NoiseSuppressor;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothHeadset;


import java.io.IOException;
import java.lang.Throwable;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.List;
import java.util.ArrayList;

import org.haxe.lime.HaxeObject;

/* 
	You can use the Android Extension class in order to hook
	into the Android activity lifecycle. This is not required
	for standard Java code, this is designed for when you need
	deeper integration.
	
	You can access additional references from the Extension class,
	depending on your needs:
	
	- Extension.assetManager (android.content.res.AssetManager)
	- Extension.callbackHandler (android.os.Handler)
	- Extension.mainActivity (android.app.Activity)
	- Extension.mainContext (android.content.Context)
	- Extension.mainView (android.view.View)
	
	You can also make references to static or instance methods
	and properties on Java classes. These classes can be included 
	as single files using <java path="to/File.java" /> within your
	project, or use the full Android Library Project format (such
	as this example) in order to include your own AndroidManifest
	data, additional dependencies, etc.
	
	These are also optional, though this example shows a static
	function for performing a single task, like returning a value
	back to Haxe from Java.
*/
public class Audiorecorder extends Extension {

	private static final String TAG = "trace[java]";
	private static int RECORDER_SAMPLERATE = 8000;
	private static int RECORDER_CHANNELS = AudioFormat.CHANNEL_IN_MONO;
	private static int RECORDER_AUDIO_ENCODING = AudioFormat.ENCODING_PCM_16BIT;
	private static int bufferSize;
	private static int readSize;
	
	private static List<Integer> mSampleRates = new ArrayList<Integer>();// { 8000, 11025, 16000, 22050, 44100 };
	private static List<Short> aformats = new ArrayList<Short>();// { AudioFormat.ENCODING_PCM_8BIT, AudioFormat.ENCODING_PCM_16BIT };
	private static List<Short> chConfigs = new ArrayList<Short>();// { AudioFormat.CHANNEL_IN_MONO, AudioFormat.CHANNEL_IN_STEREO };
	
	private static BroadcastReceiver receiver = null;
	private static AudioRecord recorder = null;
	private static NoiseSuppressor supressor = null;
	private static Thread recordingThread = null;
	
	private static AtomicBoolean isRecording = new AtomicBoolean();
	
	//todo change for update listener
	public static void startRecording(final HaxeObject callback, int size) {
		if (isRecording.get()){
			callback.call("fail", new Object[] {"already running"});//change to Throwable
			callback.call("format", new Object[] { "0,0,0" });
		}
		readSize=size;
		try{
			bufferSize = AudioRecord.getMinBufferSize(RECORDER_SAMPLERATE,
					RECORDER_CHANNELS, RECORDER_AUDIO_ENCODING) * 2;

			recorder = initFirstGood(size);
			/*new AudioRecord(MediaRecorder.AudioSource.MIC,
					RECORDER_SAMPLERATE, RECORDER_CHANNELS,
					RECORDER_AUDIO_ENCODING, bufferSize);
			*/
//			if (recorder!=null){//lets catch nullpointer exception ^_^
			recorder.startRecording();
			isRecording.set(true);
			recordingThread = new Thread(new Runnable() {
				public void run() {
					byte sData[] = new byte[readSize];
					try {
						while (isRecording.get()) {
							// gets the voice output from microphone to byte format
							recorder.read(sData, 0, readSize);
							//Log.i(TAG,"Got data");
							//pass data to haxe
							callback.call("action", new Object[] {sData});
						}
					} catch (Throwable e) {
						e.printStackTrace();
						//call error
						callback.call("fail", new Object[] {e+""});
					}
				}
			}, "AudioRecorder Thread");
			recordingThread.start();
			supressor = NoiseSuppressor.create(recorder.getAudioSessionId());
			if (supressor!=null && !supressor.isAvailable()){
				supressor.release();
				supressor=null;
			}
			callback.call0("ready");
			callback.call("format", new Object[] { RECORDER_SAMPLERATE+","+getChannels(RECORDER_CHANNELS)+","+getFormat(RECORDER_AUDIO_ENCODING) });
//			}
		}catch(Throwable e){
			callback.call("fail", new Object[] {e+" (No available config)"});//change to Throwable
		}
		callback.call("format", new Object[] { "0,0,0" });
	}

	public static void startRecordingBluetooth(final HaxeObject callback, final int size) {
		AudioManager am = (AudioManager) Extension.mainContext.getSystemService(Context.AUDIO_SERVICE);
		if (receiver!=null){
			Extension.mainContext.unregisterReceiver(receiver);
		}
		receiver=new BroadcastReceiver() {

			@Override
			public void onReceive(Context context, Intent intent) {
				int state = intent.getIntExtra(AudioManager.EXTRA_SCO_AUDIO_STATE, -1);
				Log.d(TAG, "Audio SCO state: " + state);

				if (AudioManager.SCO_AUDIO_STATE_CONNECTED == state) {
					startRecording(callback, size);
				}else if (AudioManager.SCO_AUDIO_STATE_DISCONNECTED == state){
					callback.call("fail", new Object[] {"Bluetooth disconnected"});
					//stopRecording();
				}else if (AudioManager.SCO_AUDIO_STATE_ERROR == state) { 
					callback.call("fail", new Object[] {"Bluetooth error"});
					stopRecording();
				}

			}
		};
		am.setMode(AudioManager.MODE_IN_COMMUNICATION);
		
		Extension.mainContext.registerReceiver(receiver, new IntentFilter(AudioManager.ACTION_SCO_AUDIO_STATE_CHANGED));
		Log.d(TAG, "starting bluetooth");
		am.startBluetoothSco();
	}
	
	private static int getChannels(int i){
		if (i==AudioFormat.CHANNEL_IN_STEREO)
			return 2;
		if (i==AudioFormat.CHANNEL_IN_MONO)
			return 1;
		return 0;
	}
	
	private static int getFormat(int i){
		if (i==AudioFormat.ENCODING_PCM_8BIT)
			return 1;
		if (i==AudioFormat.ENCODING_PCM_16BIT)
			return 2;
		return 4;
	}
	
	private static AudioRecord initFirstGood(int size){
		for (Short channelConfig : chConfigs) {
			RECORDER_CHANNELS=channelConfig;
			for (Integer rate : mSampleRates) {
				RECORDER_SAMPLERATE=rate;
				for (Short audioFormat : aformats) {
					RECORDER_AUDIO_ENCODING=audioFormat;
					try {
						Log.d(TAG, "Attempting rate " + rate + "Hz, bits: " + audioFormat + ", channel: " + channelConfig);
						bufferSize = AudioRecord.getMinBufferSize((int)rate, (short)channelConfig, (short)audioFormat);
						if (bufferSize != AudioRecord.ERROR_BAD_VALUE) {
							if (size>bufferSize)
								bufferSize=size;
							if (size==0)
								readSize=bufferSize;
							Log.d(TAG, "Buffer size OK "+bufferSize);
							return new AudioRecord(MediaRecorder.AudioSource.MIC,
								(int)rate, (short)channelConfig,
								(short)audioFormat, bufferSize*2);
						}
					}catch(Throwable e){
						Log.e(TAG,e+"");
					}
				}
			}
		}
		return null;
	}

	public static boolean enableSupressor(boolean mode) {
		if (supressor!=null){
			supressor.setEnabled(mode);
			return supressor.isAvailable();
		}
		return false;
	}
	
	public static void addRate(int rate) {//{ 8000, 11025, 16000, 22050, 44100 };
		mSampleRates.add(rate);
	}
	
	public static void addChanel(int num) {
		if (num==1){
			chConfigs.add((short)AudioFormat.CHANNEL_IN_MONO);
		}else if(num==2){			
			chConfigs.add((short)AudioFormat.CHANNEL_IN_STEREO);
		}
	}
	
	public static void addBits(int bits) {
		if (bits==8){
			aformats.add((short)AudioFormat.ENCODING_PCM_8BIT);			
		}else if (bits==16){
			aformats.add((short)AudioFormat.ENCODING_PCM_16BIT);
		}else if (bits==32){
			aformats.add((short)AudioFormat.ENCODING_PCM_FLOAT);
		}
	}
	
	public static void clearRates(){
		mSampleRates.clear();
	}
	
	public static void clearChanel(){
		chConfigs.clear();
	}
	
	public static void clearBits(){
		aformats.clear();
	}
	
	
	public static void stopRecording() {
		// stops the recording activity
		if (null != recorder) {
			isRecording.set(false);
			recorder.stop();
			recorder.release();
			recorder = null;
			recordingThread = null;
		}
		if (supressor!=null){
			supressor.release();
			supressor=null;
		}
		if (receiver != null){
			AudioManager am = (AudioManager) Extension.mainContext.getSystemService(Context.AUDIO_SERVICE);
			am.stopBluetoothSco();
			am.setMode(AudioManager.MODE_NORMAL);
			Extension.mainContext.unregisterReceiver(receiver);
			receiver=null;
		}
		
	}
	
	public static Boolean isHeadsetEvailable(){
		BluetoothAdapter mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
		return mBluetoothAdapter != null && mBluetoothAdapter.isEnabled()
				&& mBluetoothAdapter.getProfileConnectionState(BluetoothHeadset.HEADSET) == BluetoothHeadset.STATE_CONNECTED;
	}
	
}
