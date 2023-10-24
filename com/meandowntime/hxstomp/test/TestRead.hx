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
import com.meandowntime.hxstomp.headers.AckHeaders;
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

class TestRead extends TestCase
{
	private var mqPort:Int;
	private var mqHost:String;
	
	public function new(mqPort:Int,mqHost:String):Void {
		super();
		this.mqPort = mqPort;
		this.mqHost = mqHost;
	}

	// Read with ERROR Frame
	public function test_0300_ReadERROR() {
		TestRunner.print("\n#0300 Read with ERROR reply");
		
		var _s:ISocket = new TestSocket("[T0300]");
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		
		st.connect(mqHost, mqPort);
		// First, subscribe to the topic, so we can see that we receive the sent message
		var topic:String = "/topic/neko/T0300";
		st.subscribe(topic);
		// Now read the result
		try {
			var me = this;
			
			// Send a string with no additional headers, no sync/receipt
			st.onMessage = function(command:String, headers:Headers, body:String) {
				TestRunner.print("\n#0300 onMessage Response:\nCommand:["+command+"]\nHeaders:["+headers.toString()+"]\nBody:["+body+"]\n");
				
				// We should not have called the onMessage handler for an ERROR frame
				me.assertTrue(false); 
			}
			st.onFault = function(command:String, headers:Headers, body:String) {
				TestRunner.print("\n#0300 onFault Response:\nCommand:["+command+"]\nHeaders:["+headers.toString()+"]\nBody:["+body+"]\n");
				
				me.assertTrue(command == "ERROR");
				me.assertTrue(headers.getHeader("message") != null);
			}
			
			st.readFrame();

		} catch (e:Dynamic) {
			TestRunner.print("\n#0300 Unexpected exception "+e.toString());
			assertTrue(false);
		}
		assertTrue(true);		
	}

	
	
}