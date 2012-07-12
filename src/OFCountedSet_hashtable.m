/*
 * Copyright (c) 2008, 2009, 2010, 2011, 2012
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

#define OF_COUNTED_SET_HASHTABLE_M

#import "OFMutableSet_hashtable.h"
#import "OFCountedSet_hashtable.h"
#import "OFMutableDictionary_hashtable.h"
#import "OFString.h"
#import "OFNumber.h"
#import "OFArray.h"
#import "OFXMLElement.h"
#import "OFXMLAttribute.h"
#import "OFAutoreleasePool.h"

#import "OFInvalidArgumentException.h"
#import "OFInvalidFormatException.h"

@implementation OFCountedSet_hashtable
+ (void)initialize
{
	if (self == [OFCountedSet_hashtable class])
		[self inheritMethodsFromClass: [OFMutableSet_hashtable class]];
}

- initWithSet: (OFSet*)set
{
	self = [self init];

	@try {
		OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];

		if ([set isKindOfClass: [OFCountedSet class]]) {
			OFCountedSet *countedSet = (OFCountedSet*)countedSet;
			OFEnumerator *enumerator =
			    [countedSet objectEnumerator];
			id object;

			while ((object = [enumerator nextObject]) != nil) {
				size_t i, count;

				count = [countedSet countForObject: object];

				for (i = 0; i < count; i++)
					[self addObject: object];
			}
		} else {
			OFEnumerator *enumerator = [set objectEnumerator];
			id object;

			while ((object = [enumerator nextObject]) != nil)
				[self addObject: object];
		}

		[pool release];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- initWithArray: (OFArray*)array
{
	self = [self init];

	@try {
		id *objects = [array objects];
		size_t i, count = [array count];

		for (i = 0; i < count; i++)
			[self addObject: objects[i]];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- initWithObjects: (id const*)objects
	    count: (size_t)count
{
	self = [self init];

	@try {
		size_t i;

		for (i = 0; i < count; i++)
			[self addObject: objects[i]];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- initWithObject: (id)firstObject
       arguments: (va_list)arguments
{
	self = [self init];

	@try {
		id object;

		[self addObject: firstObject];

		while ((object = va_arg(arguments, id)) != nil)
			[self addObject: object];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- initWithSerialization: (OFXMLElement*)element
{
	self = [self init];

	@try {
		OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
		OFAutoreleasePool *pool2;
		OFArray *objects;
		OFEnumerator *enumerator;
		OFXMLElement *objectElement;

		if (![[element name] isEqual: @"OFCountedSet"] ||
		    ![[element namespace] isEqual: OF_SERIALIZATION_NS])
			@throw [OFInvalidArgumentException
			    exceptionWithClass: [self class]
				      selector: _cmd];

		objects = [element elementsForName: @"object"
					 namespace: OF_SERIALIZATION_NS];

		enumerator = [objects objectEnumerator];
		pool2 = [[OFAutoreleasePool alloc] init];

		while ((objectElement = [enumerator nextObject]) != nil) {
			OFXMLElement *object;
			OFXMLAttribute *count;
			OFNumber *number;

			object = [[objectElement elementsForNamespace:
			    OF_SERIALIZATION_NS] firstObject];
			count = [objectElement attributeForName: @"count"];

			if (object == nil || count == nil)
				@throw [OFInvalidFormatException
				    exceptionWithClass: [self class]];

			number = [OFNumber numberWithSize:
			    (size_t)[[count stringValue] decimalValue]];

			[dictionary _setObject: number
					forKey: [object objectByDeserializing]
				       copyKey: NO];

			[pool2 releaseObjects];
		}

		[pool release];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (size_t)countForObject: (id)object
{
	return [[dictionary objectForKey: object] sizeValue];
}

#ifdef OF_HAVE_BLOCKS
- (void)enumerateObjectsAndCountUsingBlock:
    (of_counted_set_enumeration_block_t)block
{
	[dictionary enumerateKeysAndObjectsUsingBlock: ^ (id key, id object,
	    BOOL *stop) {
		block(key, [object sizeValue], stop);
	}];
}
#endif

- (void)addObject: (id)object
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	OFNumber *count;

	count = [[dictionary objectForKey: object] numberByIncreasing];

	if (count == nil)
		count = [OFNumber numberWithSize: 1];

	[dictionary _setObject: count
			forKey: object
		       copyKey: NO];

	mutations++;

	[pool release];
}

- (void)removeObject: (id)object
{
	OFNumber *count = [dictionary objectForKey: object];
	OFAutoreleasePool *pool;

	if (count == nil)
		return;

	pool = [[OFAutoreleasePool alloc] init];
	count = [count numberByDecreasing];

	if ([count sizeValue] > 0)
		[dictionary _setObject: count
				forKey: object
			       copyKey: NO];
	else
		[dictionary removeObjectForKey: object];

	mutations++;

	[pool release];
}

- (void)makeImmutable
{
}
@end
