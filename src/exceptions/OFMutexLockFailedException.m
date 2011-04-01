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

#import "OFMutexLockFailedException.h"
#import "OFString.h"

#import "OFNotImplementedException.h"

@implementation OFMutexLockFailedException
+ newWithClass: (Class)class_
	 mutex: (OFMutex*)mutex
{
	return [[self alloc] initWithClass: class_
				     mutex: mutex];
}

- initWithClass: (Class)class_
{
	Class c = isa;
	[self release];
	@throw [OFNotImplementedException newWithClass: c
					      selector: _cmd];
}

- initWithClass: (Class)class_
	  mutex: (OFMutex*)mutex_
{
	self = [super initWithClass: class_];

	@try {
		mutex = [mutex_ retain];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[mutex release];

	[super dealloc];
}

- (OFString*)description
{
	if (description != nil)
		return description;

	description = [[OFString alloc] initWithFormat:
	    @"A mutex of class %@ could not be locked!", inClass];

	return description;
}

- (OFMutex*)mutex
{
	return mutex;
}
@end