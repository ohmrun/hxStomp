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
package com.meandowntime.hxstomp.exception;

class Exception
{


  private var __description : String;
  private var __infos : haxe.PosInfos;
  private var __calls : String;

  public var message(get,null) : String;
  public var source(get,null) : String;
  public var stackTrace(get,null) : String;
  public var callStack(get,null) : String;

  public function new( msg : String, ?info : haxe.PosInfos )
  {
    __description = msg;
    __calls = "Call stack available in debug mode only.";
#if debug
    var cs = haxe.Stack.callStack();
    __calls = haxe.Stack.toString( cs );
#end
    __infos = info;
	
  }

  public function get_message() : String
  {
    return __description;
  }

  public function get_source() : String
  {
    var src : String = "File: " + __infos.fileName + " | Line: " +
        __infos.lineNumber + "\n";
    src += "In method " + __infos.methodName + " of class " + 
        __infos.className;
	   return src;
  }

  public function get_stackTrace() : String
  {
    var str : String = "Exception stack available in debug mode only.";
#if debug
    var es = haxe.Stack.exceptionStack();
    str = StringTools.rpad( "StackTrace\n", "=", 21 ) + "\n";
    str += haxe.Stack.toString( es );
#end
    return str;
  }

  public function get_callStack() : String
  {
    return StringTools.rpad( "CallStackTrace\n", "=", 26 ) + "\n" + __calls;
  }

  
  public function toString() : String
  {
    var str : String = get_message() + "\n" + get_source();
    str += "\n\n" + get_stackTrace();
    str += "\n\n" + get_callStack();
    return str;
  }
}
