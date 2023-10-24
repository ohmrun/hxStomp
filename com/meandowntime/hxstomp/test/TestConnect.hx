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
import com.meandowntime.hxstomp.exception.SocketCreationException;
import com.meandowntime.hxstomp.headers.ConnectHeaders;
import com.meandowntime.hxstomp.headers.Headers;
import com.meandowntime.hxstomp.ISTOMPClient;
import com.meandowntime.hxstomp.STOMPClient;
import com.meandowntime.hxstomp.net.NekoTCPSocket;
import com.meandowntime.hxstomp.net.ISocket;
import Sys;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;

class TestConnect extends TestCase
{
	private var mqPort:Int;
	private var mqHost:String;

	public function new(mqPort:Int,mqHost:String):Void {
		super();
		this.mqPort = mqPort;
		this.mqHost = mqHost;
	}

	public function test_0010_ConnectNoHeaders() {
		var _s:ISocket = new NekoTCPSocket();
		TestRunner.print("\n#0010 TCP Connect No Headers test");
		
		do_connect_no_headers(_s, "0010");
		
	}


	public function test_0020_ConnectFullHeaders() {
		TestRunner.print("\n#0020 TCP Connect Full Headers test");
		
		var _s:ISocket = new NekoTCPSocket();
		do_connect_with_headers(_s, "0020");
	}




	private function do_connect_no_headers(sock:ISocket, testID:String) {
		
		var _s:ISocket = sock;
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		var me = this;
		st.onConnected = function(command:String,headers:Headers,body:String) {
			TestRunner.print("\n#"+testID+" Response:\nCommand:["+command+"]\nHeaders:["+headers.toString()+"]\nBody:["+body+"]\n");
			
			me.assertTrue(command.indexOf("CONNECTED") != -1);
			// make sure we get a session header
			me.assertTrue(headers != null);
			me.assertTrue(headers.getHeader("session") !=null);
		}
		
		try{
			st.connect(mqHost, mqPort);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not connect to "+mqHost+":"+mqPort);
			assertTrue(false);
		}
		st.disconnect();
		
	}
	
	private function do_connect_with_headers(sock:ISocket, testID:String) {
		
		var _s:ISocket = sock;
		var st:ISTOMPClient = new STOMPClient(_s);
		assertFalse(st == null);
		var me = this;
		st.onConnected = function(command:String,headers:Headers,body:String) {
			TestRunner.print("\n#"+testID+" Response:\nCommand:["+command+"]\nHeaders:["+headers.toString()+"]\nBody:["+body+"]\n");
			me.assertTrue(command.indexOf("CONNECTED") != -1);
			me.assertTrue(headers != null);
			me.assertTrue(headers.getHeader("session") == "id"+testID);
		}
		
		var h = new ConnectHeaders();
		h.setLogin("fred");
		h.setClientID("id"+testID);
		h.setPasscode("mypasscode");
		
		try{
			st.connect(mqHost, mqPort,h);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not connect to "+mqHost+":"+mqPort);
			assertTrue(false);
		}
		st.disconnect();
		
	}
}