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



import com.meandowntime.hxstomp.headers.AckHeaders;
import com.meandowntime.hxstomp.headers.Headers;
import com.meandowntime.hxstomp.headers.ConnectHeaders;
import com.meandowntime.hxstomp.headers.SubscribeHeaders;
import com.meandowntime.hxstomp.ISTOMPClient;
import com.meandowntime.hxstomp.net.ISocket;
import com.meandowntime.hxstomp.net.NekoTCPSocket;
import com.meandowntime.hxstomp.STOMPClient;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;

class TestSend extends TestCase
{
	private var mqPort:Int;
	private var mqHost:String;
	
	private static var MAXREADWAITLOOP:Int = 3;
	
	public function new(mqPort:Int,mqHost:String):Void {
		super();
		this.mqPort = mqPort;
		this.mqHost = mqHost;

	}

	// Subscribe+Send test with no additional headers and no sync
	public function test_0100_SendToTopicNoSync() {
		TestRunner.print("\n#0100 TCP Subscribe+Send to Topic test");
		
		var _s:ISocket = new NekoTCPSocket();
		do_SendToTopicNoSync(_s, "0100");
		
	}

	// Send +Subscribe + Read test with no additional headers and no sync
	public function test_0105_SendSubscribeReadNoSync() {
		TestRunner.print("\n#0105 TCP Send +Subscribe + Read test with no additional headers and no sync");
		
		var _s:ISocket = new NekoTCPSocket();
		do_SendSubscribeReadNoSync(_s, "0105");
	}
	// Send +Subscribe + Read test with no additional headers and no sync
	

	// Subscribe+Send test with  sync
	public function test_0110_SendToTopicWithSync() {
		TestRunner.print("\n#0110 TCP Subscribe+Send test with  sync test");
		
		var _s:ISocket = new NekoTCPSocket();
		do_SendTopicWithSync(_s, "0110");
	}

	// Send with Ack test with  sync
	public function test_0120_SendWithAckSync() {
		TestRunner.print("\n#0120 TCP Send + Ack test with  sync test");
		var _s:ISocket = new NekoTCPSocket();
		do_SendWithAckSync(_s, "0120");
		
	}
	
	
	private function do_SendToTopicNoSync(sock:ISocket, testID:String) {
		var _s:ISocket = sock;
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		
		try{
			st.connect(mqHost, mqPort);
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
		
		// Now read the result
		var res = waitForData(testID, st);
		
		if (res.loopCount == MAXREADWAITLOOP) {
			TestRunner.print("\n#"+testID+" did not received expected message ");
			
			assertTrue(false);
		} else {
			// Test that we got our message back again
			assertTrue(res.command == "MESSAGE");
			assertTrue(res.headers.getHeader("destination") == topic);
			assertTrue(res.body == msg);
		}

		st.disconnect();
		
	}
	
	private function do_SendSubscribeReadNoSync(sock:ISocket, testID:String) {
		var _s:ISocket = sock;
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		
		st.timeout = 1;
		
		try{
			st.connect(mqHost, mqPort);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not connect to "+mqHost+":"+mqPort);
			assertTrue(false);
		}
		var topic:String = "/topic/neko/"+testID;
		
		// First, send a message
		var msg = "Hello World";
		try {
			// Send a string with no additional headers, no sync/receipt
			st.sendString(topic,msg,null,false);
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not send to topic "+topic);
			assertTrue(false);
		}
		// Then, subscribe to the topic, no sync
		try {
			st.subscribe(topic);
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not subscribe to topic "+topic);
			assertTrue(false);
		}
			
		// Now read the result
		var res = waitForData(testID, st);
		
		if (res.loopCount == MAXREADWAITLOOP) {
			// Did not receive nay messages, as expected
			assertTrue(true);
		} else {
			// Test that we got our message back again
			assertTrue(res.command == "MESSAGE");
			assertFalse(res.headers.getHeader("destination") == topic);
		}
		
		
		st.disconnect();
		
	}
	
	private function do_SendTopicWithSync(sock:ISocket, testID:String) {
		var _s:ISocket = sock;
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		
		try{
			st.connect(mqHost, mqPort,true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#0"+testID+" Could not connect to "+mqHost+":"+mqPort);
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
		
		// Send a message
		var msg = "Hello World";
		try {
			// Send a string with no additional headers, with sync/receipt
			st.sendString(topic,msg,null,true);
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not send to topic and/or receive receipt from topic "+topic);
			assertTrue(false);
		}
		
		
		// Now read the result
		var res = waitForData(testID, st);
		
		if (res.loopCount == MAXREADWAITLOOP) {
			TestRunner.print("\n#"+testID+" did not received expected message ");
			
			assertTrue(false);
		} else {
			// Test that we got our message back again
			assertTrue(res.command == "MESSAGE");
			assertTrue(res.headers.getHeader("destination") == topic);
			assertTrue(res.body == msg);
			assertTrue(res.headers.getHeader("receipt") != null);
		}
		
		
		st.disconnect();
		
	}
	
	private function do_SendWithAckSync(sock:ISocket, testID:String) {
		var _s:ISocket = sock;
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		
		try{
			st.connect(mqHost, mqPort,true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not connect to "+mqHost+":"+mqPort);
			assertTrue(false);
		}
		// First, subscribe to the topic, so we can see that we receive the sent message
		var topic:String = "/topic/neko/"+testID;
		var subH:SubscribeHeaders = new SubscribeHeaders();
		subH.setAck(SubscribeHeaders.ACK_CLIENT);
		
		try {
			st.subscribe(topic,subH);
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not subscribe to topic "+topic);
			assertTrue(false);
		}
		
		// Send a message
		var msg = "Hello World from T"+testID;
		try {
			// Send a string with no additional headers, no sync/receipt
			st.sendString(topic,msg,null,true);
			assertTrue(true);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not send to topic and/or receive receipt from topic "+topic);
			assertTrue(false);
		}
		
		// Now read the result
		var res = waitForData(testID, st);
		
		if (res.loopCount == MAXREADWAITLOOP) {
			TestRunner.print("\n#"+testID+" did not received expected message ");
			
			assertTrue(false);
		} else {
			// Test that we got our message back again
			assertTrue(res.command == "MESSAGE");
			assertTrue(res.headers.getHeader("destination") == topic);
			assertTrue(res.body == msg);
			assertTrue(res.headers.getHeader("receipt") != null);
			var msgID:String = res.headers.getHeader("message-id");			
			assertTrue(msgID != null);
			
			// Send ack
			try {
				// Send ack with sync
				st.ack(msgID,null,true);
				assertTrue(true);
			} catch (e:Dynamic) {
				TestRunner.print("\n#"+testID+" Could not send ACK to topic and/or receive receipt from topic "+topic);
				assertTrue(false);
			}
			
		}
		
		

		
		st.disconnect();
		
	}
	private function waitForData(testID:String, st:ISTOMPClient):{loopCount:Int,command:String,headers:Headers,body:String} {
		
		var _command:String = null;
		var _headers:Headers = null;
		var _body:String = null;
		
		var loopCount:Int = 0;
		var dataReceived:Bool = false;
		var me = this;
		
		st.onMessage = function(command:String, headers:Headers, body:String) {
				TestRunner.print("\n#"+testID+" Response:\nCommand:["+command+"]\nHeaders:["+headers.toString()+"]\nBody:["+body+"]\n");
				
				_command = command;
				_headers = headers;
				_body = body;
				
				dataReceived = true;
				return;
			}
			
		while (!dataReceived && loopCount < MAXREADWAITLOOP) {
			try {
				st.readFrame();
				loopCount++;
			
				} catch (e:Dynamic) {
					TestRunner.print("\n#"+testID+" read error "+e.toString());
					assertTrue(false);
				}
			
		}
		
		return {loopCount:loopCount, command:_command, headers:_headers, body:_body };
		
	}
}