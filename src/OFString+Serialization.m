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

#import "OFString.h"
#import "OFString+Serialization.h"
#import "OFSerialization.h"
#import "OFArray.h"
#import "OFXMLElement.h"
#import "OFAutoreleasePool.h"

#import "OFInvalidArgumentException.h"

int _OFString_Serialization_reference;

@implementation OFString (Serialization)
- (id)objectByDeserializing
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	OFXMLElement *root = [OFXMLElement elementWithXMLString: self];
	OFArray *elements;
	id object;

	elements = [root elementsForName: @"object"
			       namespace: OF_SERIALIZATION_NS];

	if ([elements count] != 1)
		@throw [OFInvalidArgumentException newWithClass: isa
						       selector: _cmd];

	object = [[[elements firstObject] objectByDeserializing] retain];

	@try {
		[pool release];
	} @catch (id e) {
		[object release];
		@throw e;
	}

	return [object autorelease];
}
@end