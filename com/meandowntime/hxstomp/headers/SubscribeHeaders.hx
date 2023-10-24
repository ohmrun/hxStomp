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

package com.meandowntime.hxstomp.headers;

import com.meandowntime.hxstomp.headers.SharedHeaders;

 class SubscribeHeaders extends Headers
{

	
		public static var ACK : String = "ack";
		public static var ID : String = "id";
		public static var ACK_CLIENT : String = 'client';
		
		
		// The following headers are extensions that are added by ActiveMQ.
		// The header descriptions are from: http://activemq.apache.org/stomp.html
		
		/**
		 * Specifies a JMS Selector using SQL 92 syntax as specified in the JMS 1.1 specificiation. 
		 * This allows a filter to be applied to each message as part of the subscription.
		 **/
		public static var AMQ_SELECTOR : String = "selector";
		
		/**
		 * Should messages be dispatched synchronously or asynchronously from the producer thread for non-durable 
		 * topics in the broker? For fast consumers set this to false. For slow consumers set it to true so that 
		 * dispatching will not block fast consumers.
		 **/	
		public static var AMQ_DISPATCH_ASYNC : String = "activemq.dispatchAsync";
		
		/**
		 * I would like to be an Exclusive Consumer on the queue.
		 **/		
		public static var AMQ_EXCLUSIVE : String = "activemq.exclusive";
		
		/**
		 * For Slow Consumer Handling on non-durable topics by dropping old messages - we can set a maximum-pending 
		 * limit, such that once a slow consumer backs up to this high water mark we begin to discard old messages.
		 **/		
		public static var AMQ_MAXIMUM_PENDING_MESSAGE_LIMIT : String = "activemq.maximumPendingMessageLimit";
		
		/**
		 * Specifies whether or not locally sent messages should be ignored for subscriptions. Set to true to 
		 * filter out locally sent messages.
		 **/		
		public static var AMQ_NO_LOCAL : String = "activemq.noLocal";
		
		/**
		 * Specifies the maximum number of pending messages that will be dispatched to the client. Once this maximum 
		 * is reached no more messages are dispatched until the client acknowledges a message. Set to 1 for very 
		 * fair distribution of messages across consumers where processing messages can be slow.
		 **/		
		public static var AMQ_PREFETCH_SIZE : String = "activemq.prefetchSize";
		
		/**
		 * Sets the priority of the consumer so that dispatching can be weighted in priority order.
		 **/		
		public static var AMQ_PRIORITY : String = "activemq.priority";
		
		/**
		 * For non-durable topics make this subscription retroactive.
		 **/		
		public static var AMQ_RETROACTIVE : String = "activemq.retroactive";
		
		/**
		 * For durable topic subscriptions you must specify the same clientId on the connection and 
		 * subcriptionName on the subscribe. Note the spelling: subcriptionName NOT subscriptionName. 
		 * This is not intuitive, but it is how it is implemented for now.
		 **/		
		public static var AMQ_SUBSCRIPTION_NAME : String = "activemq.subcriptionName";
		
		public function setReceipt (id : String) : Void
		{
			addHeader(SharedHeaders.RECEIPT, id);
		}
				
		public function setAck (mode : String) : Void
		{
			addHeader(ACK, mode);
		}
		
		public function setId (id : String) : Void
		{
			addHeader(ID, id);
		}
		
		public function setAmqSelector (sql : String) : Void
		{
			addHeader(AMQ_SELECTOR, sql);
		}
		
		public function setAmqDispatchAsync (isAsync : String) : Void
		{
			addHeader(AMQ_DISPATCH_ASYNC, isAsync);
		}
		
		public function setAmqExclusive (isExclusive : String) : Void
		{
			addHeader(AMQ_EXCLUSIVE, isExclusive);
		}
		
		public function setAmqMaximumPendingMessageLimit (limit : String) : Void
		{
			addHeader(AMQ_MAXIMUM_PENDING_MESSAGE_LIMIT, limit);
		}
		
		public function setAmqNoLocal (ignoreLocal : String) : Void
		{
			addHeader(AMQ_NO_LOCAL, ignoreLocal);
		}
		
		public function setAmqPrefetchSize (size : String) : Void
		{
			addHeader(AMQ_PREFETCH_SIZE, size);
		}
		
		public function setAmqPriority (priority : String) : Void
		{
			addHeader(AMQ_PRIORITY, priority);
		}
		
		public function setAmqRetroactive (isRetroactive : String) : Void
		{
			addHeader(AMQ_RETROACTIVE, isRetroactive);
		}
		
		public function setAmqSubscriptionName (name : String) : Void
		{
			addHeader(AMQ_SUBSCRIPTION_NAME, name);
		}

	
}