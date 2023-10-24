/**
* ...
* @author (c) Richard J Smith 2008
*/

package com.meandowntime.hxstomp.test;

import haxe.unit.TestRunner;

import com.meandowntime.hxstomp.test.TestHTMLSTOMPClientcases;
import js.Lib;
import Dojo;

class TestHTMLSTOMPClientWrapper {

	private static var runner : TestRunner;
	private  var mqPort:Int;
	private  var mqHost:String;
	private  var orbitedDomain:String;
	private  var orbitedPort:Int;
	
	public function new(mqPort:Int,mqHost:String,orbitedDomain:String,orbitedPort:Int) {

		// Set up client environment
		this.mqPort = mqPort;
		this.mqHost = mqHost;
		this.orbitedDomain = orbitedDomain;
		this.orbitedPort = orbitedPort;

		runner = new TestRunner();
		
		TestRunner.print("\nMust have ActiveMQ running stomp on port 61613 and Orbited daemon\n");
		
		runner.add(new TestHTMLSTOMPClientcases(mqPort,mqHost,orbitedDomain,orbitedPort));
		
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
		
		TestRunner.print("\n** setupTestSuite() **\n");

	}
	
	/**
	 * Carries out one-time teardown / close out tasks before Test Suite ends
	 * 
	 */
	private function tearDownTestSuite() {
		
		TestRunner.print("\n** tearDownTestSuite() **\n");
		
	}
	
	
}