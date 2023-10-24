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

package com.meandowntime.hxstomp.test.main;

import haxe.unit.TestRunner;
import com.meandowntime.hxstomp.test.TestInstantiation;
import com.meandowntime.hxstomp.test.TestConnect;
import com.meandowntime.hxstomp.test.TestSubscribe;
import com.meandowntime.hxstomp.test.TestSend;
import com.meandowntime.hxstomp.test.TestRead;
import com.meandowntime.hxstomp.test.TestTransaction;
import com.meandowntime.hxstomp.test.TestExceptions;


class TestSTOMPClient {

	private static var runner : TestRunner;
	private static var tests : TestSTOMPClient;
	private static var mqPort:Int;
	private static var mqHost:String;
	
	public function new() {

		// Set up client environment

		runner = new TestRunner();
		
		TestRunner.print("\nMust have ActiveMQ running STOMP on port 61613");
		
		
		runner.add(new TestInstantiation());
		runner.add(new TestConnect(mqPort, mqHost));
		
		runner.add(new TestSubscribe(mqPort,mqHost));
		runner.add(new TestSend(mqPort, mqHost));
		runner.add(new TestRead(mqPort, mqHost));
		runner.add(new TestTransaction(mqPort, mqHost));
		runner.add(new TestExceptions(mqPort, mqHost));
	
		// Run test suite
		setupTestSuite();	// Neko compiler seems to want this call after the runner.add method calls.

		runner.run();

		tearDownTestSuite();

		

	}
	
	/**
	 * Carries out one-time set up tasks for the whole test suite contained in this class
	 * 
	 */
	private function setupTestSuite() {
		
		TestRunner.print("** setupTestSuite() **\n");

	}
	
	/**
	 * Carries out one-time teardown / close out tasks before Test Suite ends
	 * 
	 */
	private function tearDownTestSuite() {
		
		TestRunner.print("** tearDownTestSuite() **\n");
		
	}
	
	public static function main() {
		
		mqPort = 61613;
		mqHost = "localhost";
		
		tests = new TestSTOMPClient();
		
	}
	
}