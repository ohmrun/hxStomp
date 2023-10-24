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


import com.meandowntime.hxstomp.frame.FrameReader;
import com.meandowntime.hxstomp.headers.Headers;
import com.meandowntime.hxstomp.headers.ConnectHeaders;
import com.meandowntime.hxstomp.headers.SendHeaders;
import com.meandowntime.hxstomp.headers.SubscribeHeaders;
import com.meandowntime.hxstomp.ISTOMPClient;
import com.meandowntime.hxstomp.net.ISocket;
import com.meandowntime.hxstomp.net.NekoTCPSocket;
import com.meandowntime.hxstomp.STOMPClient;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;

class TestTransaction extends TestCase
{
	private var mqPort:Int;
	private var mqHost:String;
	
	public function new(mqPort:Int,mqHost:String):Void {
		super();
		this.mqPort = mqPort;
		this.mqHost = mqHost;
	}

	// Transaction with Commit No Sync
	public function test_0200_TranWithCommitNoSync() {
		TestRunner.print("\n#0200 Transaction with Commit No Sync test");
		
		var _s:ISocket = new NekoTCPSocket();
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		
		try{
			st.connect(mqHost, mqPort);
		} catch (e:Dynamic) {
			TestRunner.print("\n#0200 Could not connect to "+mqHost+":"+mqPort);
			assertTrue(false);
		}
		// First, subscribe to the topic, so we can see that we receive the sent message
		var topic:String = "/topic/neko/T0200";
		try {
			st.subscribe(topic);
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#0200 Could not subscribe to topic "+topic);
			assertTrue(false);
		}
		
		// Start a transaction
		var tran = "T0200-1";
		try {
			// Send a Commit
			st.begin(tran,null,false);
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#0200 Could not send a BEGIN to topic "+topic);
			assertTrue(false);
		}
		
		// Send a message in the transaction
		var msg = "Hello World from T0200";
		var h:com.meandowntime.hxstomp.headers.SendHeaders = new SendHeaders();
		h.setTransaction(tran);
		try {
			// Send a string with no additional headers, no sync/receipt
			st.sendString(topic,msg,h,false);
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#0200 Could not send to topic "+topic);
			assertTrue(false);
		}
		// Send another message in the same transaction
		var msg = "Hello World Again from T0200";
		try {
			// Send a string with no additional headers, no sync/receipt
			st.sendString(topic,msg,h,false);
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#0200 Could not send to topic "+topic);
			assertTrue(false);
		}

		// Commit the transaction
		try {
			// Send a Commit
			st.commit(tran,null,false);
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#0200 Could not send a COMMIT to topic "+topic);
			assertTrue(false);
		}
		
		
		// Now read the result - expected to get both messages
		try {
			var me = this;
			
			// Read a string with no additional headers, no sync/receipt
			st.onMessage = function(command:String, headers:Headers, body:String) {
				TestRunner.print("\n#0200 Response:\nCommand:["+command+"]\nHeaders:["+headers.toString()+"]\nBody:["+body+"]\n");
				
				// Test that we got our message back again
				me.assertTrue(command == "MESSAGE");
				me.assertTrue(headers.getHeader("destination") == topic);
				me.assertTrue(headers.getHeader("transaction") == tran);
			}
			st.readFrame();
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#0200 Could not receive from topic "+topic);
			assertTrue(false);
		}
		try {
			var me = this;
			
			// Read a string with no additional headers, no sync/receipt
			st.onMessage = function(command:String, headers:Headers, body:String) {
				TestRunner.print("\n#0200 Response:\nCommand:["+command+"]\nHeaders:["+headers.toString()+"]\nBody:["+body+"]\n");
				
				// Test that we got our message back again
				me.assertTrue(command == "MESSAGE");
				me.assertTrue(headers.getHeader("destination") == topic);
				me.assertTrue(headers.getHeader("transaction") == tran);
			}
			st.readFrame();
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#0200 Could not receive from topic "+topic);
			assertTrue(false);
		}
		
		st.disconnect();
		
	}

	
	
}