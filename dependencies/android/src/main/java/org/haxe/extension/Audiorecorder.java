package org.haxe.extension;


import android.app.Activity;
import android.content.res.AssetManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.media.AudioRecord;
import android.media.AudioFormat;
import android.media.MediaRecorder;
import android.media.AudioManager;
import android.util.Log;
import android.media.audiofx.NoiseSuppressor;


import java.io.IOException;
import java.lang.Throwable;
import java.util.concurrent.atomic.AtomicBoolean;

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
	
	private static AudioRecord recorder = null;
	private static NoiseSuppressor supressor = null;
	private static Thread recordingThread = null;
	
	private static AtomicBoolean isRecording = new AtomicBoolean();
	
	//todo change for update listener
	public static String startRecording(final HaxeObject callback, int size) {
		if (isRecording.get()){
			callback.call("fail", new Object[] {-1});//change to Throwable
			return "-1,0,0";
		}
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
					byte sData[] = new byte[bufferSize];
					try {
						while (isRecording.get()) {
							// gets the voice output from microphone to byte format
							recorder.read(sData, 0, bufferSize);
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
			return RECORDER_SAMPLERATE+","+getChannels(RECORDER_CHANNELS)+","+getFormat(RECORDER_AUDIO_ENCODING);
//			}
		}catch(Throwable e){
			callback.call("fail", new Object[] {e+""});//change to Throwable
		}
		return "0,0,0";
	}

	public static void startRecordingBluetooth(final HaxeObject callback, final HaxeObject result, int size) {
/*		am = (AudioManager) getSystemService(Context.AUDIO_SERVICE);

		context.registerReceiver(new BroadcastReceiver() {

			@Override
			public void onReceive(Context context, Intent intent) {
				int state = intent.getIntExtra(AudioManager.EXTRA_SCO_AUDIO_STATE, -1);
				Log.d(TAG, "Audio SCO state: " + state);

				if (AudioManager.SCO_AUDIO_STATE_CONNECTED == state) { 
					
					unregisterReceiver(this);
				}

			}
		}, new IntentFilter(AudioManager.ACTION_SCO_AUDIO_STATE_CHANGED));

		Log.d(TAG, "starting bluetooth");
		am.startBluetoothSco();
*/	}
	
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
		int[] mSampleRates = new int[] { 8000, 11025, 16000, 22050, 44100 };
		short [] aformats = new short[] { AudioFormat.ENCODING_PCM_8BIT, AudioFormat.ENCODING_PCM_16BIT };
		short [] chConfigs = new short[] { AudioFormat.CHANNEL_IN_MONO, AudioFormat.CHANNEL_IN_STEREO };
		for (short channelConfig : chConfigs) {
			RECORDER_CHANNELS=channelConfig;
			for (int rate : mSampleRates) {
				RECORDER_SAMPLERATE=rate;
				for (short audioFormat : aformats) {
					RECORDER_AUDIO_ENCODING=audioFormat;
					try {
						Log.d(TAG, "Attempting rate " + rate + "Hz, bits: " + audioFormat + ", channel: " + channelConfig);
						bufferSize = AudioRecord.getMinBufferSize(rate, channelConfig, audioFormat);
						if (bufferSize != AudioRecord.ERROR_BAD_VALUE) {
							if (size>bufferSize)
								bufferSize=size;
							Log.d(TAG, "Buffer size OK "+bufferSize);
							return new AudioRecord(MediaRecorder.AudioSource.MIC,
								rate, channelConfig,
								audioFormat, bufferSize*2);
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
	}
	
}
