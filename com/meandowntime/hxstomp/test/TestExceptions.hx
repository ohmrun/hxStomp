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
import com.meandowntime.hxstomp.exception.IncorrectReceiptException;
import com.meandowntime.hxstomp.exception.InvalidArgumentsException;
import com.meandowntime.hxstomp.exception.ReceiptTimeoutException;
import com.meandowntime.hxstomp.exception.SocketCreationException;
import com.meandowntime.hxstomp.exception.SocketReadException;
import com.meandowntime.hxstomp.exception.SocketWriteException;
import com.meandowntime.hxstomp.headers.Headers;
import com.meandowntime.hxstomp.headers.ConnectHeaders;
import com.meandowntime.hxstomp.headers.SubscribeHeaders;
import com.meandowntime.hxstomp.ISTOMPClient;
import com.meandowntime.hxstomp.net.ISocket;
import com.meandowntime.hxstomp.net.NekoTCPSocket;
import com.meandowntime.hxstomp.STOMPClient;
import com.meandowntime.hxstomp.test.helper.TestSocket;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;

class TestExceptions extends TestCase
{
	private var mqPort:Int;
	private var mqHost:String;
	
	public function new(mqPort:Int,mqHost:String):Void {
		super();
		this.mqPort = mqPort;
		this.mqHost = mqHost;
	}

	public function test_1000_1_ConnectExceptionHandling() {
		TestRunner.print("\n#1000_1 Connect Exception Handling test");
		
		// PART 1 test socket opening exception handling
		var _s:ISocket = new TestSocket("[T1000]");
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		var me = this;
		st.timeout = 1;
		try{
			st.connect("dummy.host.com", 80);
		} catch (e:SocketCreationException) {
			assertTrue(true);
			return;
		} catch (e:Dynamic ) {
			// Some other exception raised
			TestRunner.print("\n#1000 Unexpected Exception raised:\n" + e.toString());
			assertTrue(false);
		}
		assertTrue(false); // Should not get here
				
	}

	public function test_1000_2_ConnectExceptionHandling() {
		TestRunner.print("\n#1000-2 Connect Exception Handling test");
		
		
		// PART 2 test Connect write exception handling
		var _s = new TestSocket("[T1000-1]");
		var st = new STOMPClient(_s);
		assertFalse(st == null);
		var me = this;
		st.timeout = 1;
		try{
			st.connect("dummy.host.com", 80);
		} catch (e:SocketWriteException) {
			assertTrue(true);
			return;
		} catch (e:Dynamic ) {
			// Some other exception raised
			TestRunner.print("\n#1000-2 Unexpected Exception raised:\n" + e.toString());
			assertTrue(false);
		}
		assertTrue(false); // Should not get here		
		
	}

	public function test_1000_3_ConnectExceptionHandling() {
		TestRunner.print("\n#1000-3 Connect Exception Handling test");
		
		
		// PART 3 Connection read handling
		var _s = new TestSocket("[T1000-3]");
		var st = new STOMPClient(_s);
		assertFalse(st == null);
		var me = this;
		st.timeout = 1;
		try{
			st.connect("dummy.host.com", 80);
		} catch (e:SocketReadException) {
			assertTrue(true);
			return;
		} catch (e:Dynamic ) {
			// Some other exception raised
			TestRunner.print("\n#1000-3 Unexpected Exception raised:\n" + e.toString());
			assertTrue(false);
		}
		
		assertTrue(false);
	}

	public function test_1005_InvalidHostPortException() {
		TestRunner.print("\n#1005 Invalid Host Exception test");
		var st:ISTOMPClient;
		
		try {
			st = new STOMPClient(null);
			assertTrue(false);
			return;
		} catch (e:InvalidArgumentsException) {
			assertTrue(true);
		} catch (e:Dynamic) {
			assertTrue(false);
			return;
		}
		
		var _s:ISocket = new TestSocket("T1005");
		st = new STOMPClient(_s);
		assertFalse(st == null);
		
		try {
			st.connect(null, null);
			assertTrue(false);
		} catch (e:InvalidArgumentsException) {
			assertTrue(true);
		} catch (e:Dynamic) {
			assertTrue(false);
			return;
		}
		
	}
	public function test_1010_SubscribeWriteException() {
		TestRunner.print("\n#1010 Subscribe Write Exception test");
		
		var _s:ISocket = new TestSocket("T1010");
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		
		st.connect(mqHost, mqPort);
		
		var topic:String = "/topic/neko/T1010";
		try {
			st.subscribe(topic);
			assertTrue(true);
		} catch (e:SocketWriteException) {
			TestRunner.print("\n#1010 SocketWriteException raised:\n" );
			assertTrue(!st.isAvailable());
			assertTrue(true);
			return;
		} catch (e:Dynamic) {
			TestRunner.print("\n#1010 Unexpected exception raised:\n"+e.toString());
			assertTrue(false);
		}
		assertTrue(false);
	}

	public function test_1020_SendTextWriteException() {
		TestRunner.print("\n#1020 SendText Write Exception test");
		
		var _s:ISocket = new TestSocket("T1020");
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		
		st.connect(mqHost, mqPort);
		
		var topic:String = "/topic/neko/T1020";
		st.subscribe(topic);
		
		try {
			st.sendString(topic, "Hello world");
		} catch (e:SocketWriteException) {
			TestRunner.print("\n#1020 SocketWriteException raised:\n");
			assertTrue(!st.isAvailable());
			assertTrue(true);
			return;
		} catch (e:Dynamic) {
			TestRunner.print("\n#1020 Unexpected exception raised:\n"+e.toString());
			assertTrue(false);
		}
		assertTrue(false);
	}
	
	public function test_1030_1_SocketReadException() {
		TestRunner.print("\n#1030_1 Socket Read Exception test");
		
		// PART 1: Read with hasFrameToRead failure
		var _s:ISocket = new TestSocket("[T1030-1]");
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		
		st.connect(mqHost, mqPort);
		
		var topic:String = "/topic/neko/T1030-1";
		st.subscribe(topic,null);
		
		try {
			st.readFrame();
		} catch (e:SocketReadException) {
			TestRunner.print("\n#1030_1 SocketReadException raised:\n" );
			assertTrue(!st.isAvailable());
			assertTrue(true);
			return;
		} catch (e:Dynamic) {
			TestRunner.print("\n#1030_1 Unexpected exception raised:\n"+e.toString());
			assertTrue(false);
		}
		
		assertTrue(false);
				
	}

	public function test_1030_2_SocketReadException() {
		TestRunner.print("\n#1030_2 Socket Read Exception test");
		
		// PART 1: Read with socket.readChar failure
		var _s:ISocket = new TestSocket("[T1030-2]");
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		
		st.connect(mqHost, mqPort);
		
		var topic:String = "/topic/neko/T1030-2";
		st.subscribe(topic,null);
		
		try {
			st.readFrame();
		} catch (e:SocketReadException) {
			TestRunner.print("\n#1030_2 SocketReadException raised:\n" );
			assertTrue(!st.isAvailable());
			assertTrue(true);
			return;
		} catch (e:Dynamic) {
			TestRunner.print("\n#1030_2 Unexpected exception raised:\n"+e.toString());
			assertTrue(false);
		}
		
		assertTrue(false);
				
	}
	
	public function test_1040_1_SubscribeReceiptException() {
		TestRunner.print("\n#1040_1 Subscribe Receipt Exception test");
		
		var _s:ISocket = new TestSocket("[T1040-1]");
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		
		st.connect(mqHost, mqPort,true);
		st.timeout = 1;
		var topic:String = "/topic/neko/T1040-1";
		try {
			st.subscribe(topic,null);
		} catch (e:IncorrectReceiptException) {
			TestRunner.print("\n#1040_1 IncorrectReceiptException raised:\n" );
			assertTrue(!st.isAvailable());
			assertTrue(true);
			return;
		} catch (e:Dynamic) {
			TestRunner.print("\n#1040-1 Unexpected exception raised:\n"+e.toString());
			assertTrue(false);
		}
		
		assertTrue(false);
		
	}

	public function test_1040_2_SubscribeReceiptException() {
		TestRunner.print("\n#1040_2 Subscribe Receipt ERROR Frame Exception test");
		
		var _s:ISocket = new TestSocket("[T1040-2]");
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		
		st.connect(mqHost, mqPort,true);
		st.timeout = 1;
		var topic:String = "/topic/neko/T1040-2";
		var me = this;
		st.onFault = function (command:String, headers:Headers, body:String) {
				TestRunner.print("\n#1040-2 Response:\nCommand:["+command+"]\nHeaders:["+headers.toString()+"]\nBody:["+body+"]\n");
				
				// Test that we got a ERROR message frame
				me.assertTrue(command == "ERROR");
				
		}
		
		try {
			st.subscribe(topic,null);
		} catch (e:Dynamic) {
			TestRunner.print("\n#1040-2 Unexpected exception raised:\n"+e.toString());
			assertTrue(false);
		}
		
		assertTrue(true);	// In this case, we expect to get here, because the onFault callback was used, not an exception
		
	}
	
	public function test_1050_ReceiptTimeoutException() {
		TestRunner.print("\n#1050 Subscribe Receipt Timeout Exception test");
		
		var _s:ISocket = new TestSocket("[T1050]");
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		
		st.connect(mqHost, mqPort, true);
		st.timeout = 0.1;
		var topic:String = "/topic/neko/T1050";
		var me = this;
		
		try {
			st.subscribe(topic, null);
		} catch (e:ReceiptTimeoutException) {
			TestRunner.print("\n#1050 IncorrectReceiptException raised:\n"+e.toString() );
			assertTrue(!st.isAvailable());
			assertTrue(true);
			return;
		} catch (e:Dynamic) {
			TestRunner.print("\n#1050 Unexpected exception raised:\n"+e.toString());
			assertTrue(false);
		}
		
		assertTrue(false);	
		
	}
	
}