/**
* ...
* @author DefaultUser (Tools -> Custom Arguments...)
*/

package com.meandowntime.hxstomp.test;

import com.meandowntime.hxstomp.HTMLSTOMPClientWrapper;
import com.meandowntime.hxstomp.ISTOMPClient;
import com.meandowntime.hxstomp.headers.Headers;
import js.Lib;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;


class TestHTMLSTOMPClientcases extends TestCase
{
	private static var MAXREADWAITLOOP:Int = 3;

	private var mqPort:Int;
	private var mqHost:String;
	private var orbitedDomain:String;
	private var orbitedPort:Int;
	
	public function new(mqPort:Int,mqHost:String,orbitedDomain:String,orbitedPort:Int):Void {
		super();
		this.mqPort = mqPort;
		this.mqHost = mqHost;
		this.orbitedDomain = orbitedDomain;
		this.orbitedPort = 8001;
	}
	
	public function _test_0001_Instantiation():Void {
		TestRunner.print("\n#0001 Instantiation test");

		var st:ISTOMPClient = new HTMLSTOMPClientWrapper(orbitedDomain, orbitedPort);
		assertFalse(st == null);
		
	}
	
	public function test_0010_Connect():Void {
		
		var testID:String = "0010";
		TestRunner.print("\n#"+testID+" Connection test");

		var st:ISTOMPClient = new HTMLSTOMPClientWrapper(orbitedDomain, orbitedPort);
		assertTrue(st != null);
		
		var me = this;
		
		try
		{
			trace ("try to connect to host"+mqHost+" port="+mqPort);
			st.connect(mqHost, mqPort);
		} catch (e:Dynamic) {
			TestRunner.print("\n#"+testID+" Could not connect to "+mqHost+":"+mqPort+",error ="+Std.string(e));
			assertTrue(false);
		}
		// Now read the result
		var res = waitForData(testID, st);
		
			// Test that we got our message back again
			assertTrue(res.command == "CONNECTED");
			assertFalse(res.headers.getHeader("session") != null);

		
		
		st.disconnect();
	}	
	
	private function waitForData(testID:String, st:ISTOMPClient):{loopCount:Int,command:String,headers:Headers,body:String} {
		
		var _command:String = null;
		var _headers:Headers = null;
		var _body:String = null;
		
		var loopCount:Int = 0;
		var dataReceived:Bool = false;
		var me = this;
		st.onConnected = function(command:String, headers:Headers, body:String) {
				TestRunner.print("\n#"+testID+" Response:\nCommand:["+command+"]\nHeaders:["+headers.toString()+"]\nBody:["+body+"]\n");
				
				_command = command;
				_headers = headers;
				_body = body;
				
				dataReceived = true;
				return;
			}
		
		st.onMessage = function(command:String, headers:Headers, body:String) {
				TestRunner.print("\n#"+testID+" Response:\nCommand:["+command+"]\nHeaders:["+headers.toString()+"]\nBody:["+body+"]\n");
				
				_command = command;
				_headers = headers;
				_body = body;
				
				dataReceived = true;
				return;
			}
			
		while (!dataReceived) {
			try {
				
				st.readFrame();
				
			
				} catch (e:Dynamic) {
					TestRunner.print("\n#"+testID+" read error "+e.toString());
					assertTrue(false);
				}
			
		}
		
		return {loopCount:loopCount, command:_command, headers:_headers, body:_body };
		
	}
	
}