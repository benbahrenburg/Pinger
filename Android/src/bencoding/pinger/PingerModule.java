/**
 *
 * Copyright (c) 2013 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 **/
package bencoding.pinger;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.annotations.Kroll;

import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.TiC;

@Kroll.module(name="Pinger", id="bencoding.pinger")
public class PingerModule extends KrollModule
{

	// Standard Debugging variables
	//private static final String TAG = "bencoding.pinger";	
	public PingerModule()
	{
		super();
	}

	@Kroll.onAppCreate
	public static void onAppCreate(TiApplication app)
	{
		//Log.d(TAG, "inside onAppCreate");
		// put module init code that needs to run when the application is created
	}

	// Methods
	@SuppressWarnings({ "rawtypes", "unchecked" })
	@Kroll.method
	public void ping(HashMap hm)
	{
		KrollDict args = new KrollDict(hm);

		if(!args.containsKey("completed")){
			throw new IllegalArgumentException("missing completed callback method");
		}
		if(!args.containsKey("address")){
			throw new IllegalArgumentException("missing address");
		}
		String address = args.getString("address");
		boolean hasPrefix = ((address.toLowerCase().contains("http://".toLowerCase()))) ||(address.toLowerCase().contains("http://".toLowerCase()));
		if(!hasPrefix){
			address="http://"+ address;
		}
		address = address.replaceFirst("https", "http"); // Otherwise an exception may be thrown on invalid SSL certificates.
		KrollFunction callback = null;
		Object object = args.get("completed");
		if (object instanceof KrollFunction) {
			callback = (KrollFunction)object;
		}
		int timeout = args.optInt("timeout", 1500);

		boolean success = false;
		String message = "waiting";
		long startTime = System.currentTimeMillis();
		 HttpURLConnection connection = null;
		try {
			connection = (HttpURLConnection) new URL(address).openConnection();
			connection.setConnectTimeout(timeout);
			connection.setReadTimeout(timeout);
			connection.setRequestMethod("HEAD");
			int responseCode = connection.getResponseCode();
			message ="connected successfully";
			success = (200 <= responseCode && responseCode <= 399);
			message = (success) ? "connected successfully" : "Failed with response code:" + responseCode;
		} catch (IOException exception) {
			message = exception.toString();
			success = false;
		}
		finally{
		    if (connection != null) {
		        connection.disconnect();
		    }					
		}
		long endTime = System.currentTimeMillis();
		long duration = (endTime-startTime);
		
		HashMap<String, Object> event = new HashMap<String, Object>();
		event.put(TiC.PROPERTY_SUCCESS, success);	
		event.put("address",address);	
		event.put("message",message);
		event.put("duration", duration);
		if(callback!=null){		
			callback.call(getKrollObject(), event);
		}			
	}

}

