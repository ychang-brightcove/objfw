/*
 * Copyright (c) 2008, 2009, 2010, 2011
 *   Jonathan Schleifer <js@webkeks.org>
 *
 * All rights reserved.
 *
 * This file is part of ObjFW. It may be distributed under the terms of the
 * Q Public License 1.0, which can be found in the file LICENSE.QPL included in
 * the packaging of this file.
 *
 * Alternatively, it may be distributed under the terms of the GNU General
 * Public License, either version 2 or 3, which can be found in the file
 * LICENSE.GPLv2 or LICENSE.GPLv3 respectively included in the packaging of this
 * file.
 */

#include "config.h"

#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <assert.h>

#import "OFHTTPRequest.h"
#import "OFString.h"
#import "OFThread.h"
#import "OFTCPSocket.h"
#import "OFURL.h"
#import "OFAutoreleasePool.h"

#import "TestsAppDelegate.h"

static OFString *module = @"OFHTTPRequest";
static OFCondition *cond;

@interface OFHTTPRequestTestsServer: OFThread
{
@public
	uint16_t port;
}
@end

@implementation OFHTTPRequestTestsServer
- main
{
	OFTCPSocket *listener, *client;

	[cond lock];

	listener = [OFTCPSocket socket];
	[listener bindToPort: port
		      onHost: @"127.0.0.1"];
	[listener listen];

	[cond signal];
	[cond unlock];

	client = [listener accept];

	if (![[client readLine] isEqual: @"GET /foo HTTP/1.0"])
		assert(0);

	if (![[client readLine] isEqual:
	    [OFString stringWithFormat: @"Host: 127.0.0.1:%" @PRIu16, port]])
		assert(0);

	if (![[client readLine] hasPrefix: @"User-Agent:"])
		assert(0);

	if (![[client readLine] isEqual: @""])
		assert(0);

	[client writeString: @"HTTP/1.0 200 OK\r\n"
			     @"Content-Length: 7\r\n"
			     @"\r\n"
			     @"foo\n"
			     @"bar"];
	[client close];

	return nil;
}
@end

@implementation TestsAppDelegate (OFHTTPRequesTests)
- (void)HTTPRequestTests
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	OFHTTPRequestTestsServer *server;
	OFURL *url;
	OFHTTPRequest *req;
	OFHTTPRequestResult *res;

	cond = [OFCondition condition];
	[cond lock];

	server = [[[OFHTTPRequestTestsServer alloc] init] autorelease];
	/* srand(time(NULL)) was already called by OFTCPSocket */
	server->port = (uint16_t)rand();
	if (server->port < 1024)
		server->port += 1024;
	[server start];

	url = [OFURL URLWithString:
	    [OFString stringWithFormat: @"http://127.0.0.1:%" @PRIu16 "/foo",
					server->port]];

	TEST(@"+[request]", (req = [OFHTTPRequest request]))
	TEST(@"-[setURL:]", R([req setURL: url]))

	[cond wait];
	[cond unlock];

	TEST(@"-[perform]", (res = [req perform]))

	[server join];

	[pool drain];
}
@end