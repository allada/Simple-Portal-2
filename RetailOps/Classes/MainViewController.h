/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import <UIKit/UIKit.h>
#import "Cordova/CDVViewController.h"

#define AF_INET 2
#define	SOCK_STREAM	1		/* stream socket */
#define	IPPROTO_TCP		6		/* tcp */
#define	SOL_SOCKET	0xffff		/* options for socket level */
#define	SO_REUSEADDR	0x0004		/* allow local address reuse */
typedef __uint8_t		sa_family_t;
struct in_addr {
	in_addr_t s_addr;
};
struct sockaddr_in {
	__uint8_t	sin_len;
	sa_family_t	sin_family;
	in_port_t	sin_port;
	struct	in_addr sin_addr;
	char		sin_zero[8];
};

@interface ViewController : CDVViewController{
    CFSocketRef socket;
    NSFileHandle *listeningHandle;
	NSMutableDictionary *incomingRequests;
	NSMutableSet *responseHandlers;
    NSLock *requestsLock;
}
extern NSString * const HTTPServerNotificationStateChanged;
@end
