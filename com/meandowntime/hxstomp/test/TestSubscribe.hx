/*
Copyright (c) 2008, Richard J Smith

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.meandowntime.hxstomp.test;


import com.meandowntime.hxstomp.exception.Exception;
import com.meandowntime.hxstomp.headers.Headers;
import com.meandowntime.hxstomp.headers.ConnectHeaders;
import com.meandowntime.hxstomp.headers.SubscribeHeaders;
import com.meandowntime.hxstomp.ISTOMPClient;
import com.meandowntime.hxstomp.net.ISocket;
import com.meandowntime.hxstomp.net.NekoTCPSocket;
import com.meandowntime.hxstomp.STOMPClient;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;

class TestSubscribe extends TestCase
{
	private var mqPort:Int;
	private var mqHost:String;
	
	public function new(mqPort:Int,mqHost:String):Void {
		super();
		this.mqPort = mqPort;
		this.mqHost = mqHost;
	}


	public function test_0030_SubscribeTopicNoHeadersNoSync() {
		TestRunner.print("\n#0030 TCP Subscribe No Headers test");
		
		var _s:ISocket = new NekoTCPSocket();
		do_SubscribeTopicNoHeadersNoSync(_s, "0030");
	}

	
	public function test_0035_SubscribeQueueNoHeadersNoSync() {
		TestRunner.print("\n#0035 TCP Subscribe Queue No Headers test");
		var _s:ISocket = new NekoTCPSocket();
		
		do_SubscribeQueueNoHeadersNoSync(_s, "0035");
	}


	public function test_0040_SubscribeTopicNoHeadersWithSync() {
		TestRunner.print("\n#0040 TCP Subscribe No Headers With Sync test");
		
		var _s:ISocket = new NekoTCPSocket();
		do_SubscribeTopicNoHeadersWithSync(_s, "0040");
	}


	// Unsubscribe test with no additional headers and no sync
	public function test_00050_UnsubscribeNoSync() {
		TestRunner.print("\n#0050 TCP Unsubscribe to Topic test");
		
		var _s:ISocket = new NekoTCPSocket();
		do_UnsubscribeNoSync(_s, "0050");
		
	}

	
	private function do_SubscribeTopicNoHeadersNoSync(sock:ISocket, testID:String) {
		var _s:ISocket = sock;
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		
		try{
			st.connect(mqHost, mqPort);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not connect to "+mqHost+":"+mqPort);
			assertTrue(false);
		}
		var topic:String = "/topic/neko/T"+testID;
		try {
			st.subscribe(topic);
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not subscribe to topic "+topic);
			assertTrue(false);
		}
		
		st.disconnect();
		
	}
	
	private function do_SubscribeQueueNoHeadersNoSync(sock:ISocket, testID:String) {
		var _s:ISocket = sock;
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		
		try{
			st.connect(mqHost, mqPort);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not connect to "+mqHost+":"+mqPort);
			assertTrue(false);
		}
		var topic:String = "/queue/neko/test_"+testID;
		try {
			st.subscribe(topic);
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not subscribe to topic "+topic);
			assertTrue(false);
		}
		
		st.disconnect();
		
	}
	
	private function do_SubscribeTopicNoHeadersWithSync(sock:ISocket, testID:String) {
		var _s:ISocket = sock;
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		
		try{
			st.connect(mqHost, mqPort,true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not connect to "+mqHost+":"+mqPort+" with error "+e);
			assertTrue(false);
		}
		var topic:String = "/topic/neko/"+testID;
		try {
			st.subscribe(topic,null,true);
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not subscribe to topic "+topic);
			assertTrue(false);
		}
		
		st.disconnect();
		
	}
	
	private function do_UnsubscribeNoSync(sock:ISocket, testID:String) {
		var _s:ISocket = sock;
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		
		try
		{
			// Connect - no sync
			st.connect(mqHost, mqPort,null,false);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not connect to "+mqHost+":"+mqPort);
			assertTrue(false);
		}
		// First, subscribe to the topic, so we can see that we receive the sent message
		var topic:String = "/topic/neko/"+testID;
		try {
			st.subscribe(topic);
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not subscribe to topic "+topic);
			assertTrue(false);
		}
		
		// unsubscribe from the topic, so we can see that we receive the sent message
		try {
			st.unsubscribe(topic);
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not unsubscribe to topic "+topic);
			assertTrue(false);
		}
		// Send a message
		var msg = "Hello World";
		try {
			// Send a string with no additional headers, no sync/receipt
			st.sendString(topic,msg,null,false);
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not send to topic "+topic);
			assertTrue(false);
		}
		
		// Now read the result, with short timeout
		st.timeout = 1;
		
		try {
			var me = this;
			
			// If there was something in the queue from topic, fail the test
			st.onMessage = function(command:String, headers:Headers, body:String) {
				TestRunner.print("\n#"+testID+" Response:\nCommand:["+command+"]\nHeaders:["+headers.toString()+"]\nBody:["+body+"]\n");
				
				// Test that we got our message back again
				me.assertTrue(command == "MESSAGE");
				me.assertTrue(headers.getHeader("destination") != topic);
			}
			st.readFrame();
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not receive from topic "+topic);
			assertTrue(false);
		}
		
		st.disconnect();
		
	}
}