/*
 * Copyright (c) 2008 - 2009
 *   Jonathan Schleifer <js@webkeks.org>
 *
 * All rights reserved.
 *
 * This file is part of libobjfw. It may be distributed under the terms of the
 * Q Public License 1.0, which can be found in the file LICENSE included in
 * the packaging of this file.
 */

#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

#import "OFDataArray.h"
#import "OFAutoreleasePool.h"
#import "OFExceptions.h"

#define CATCH_EXCEPTION(code, exception)		\
	@try {						\
		code;					\
							\
		puts("NOT CAUGHT!");			\
		return 1;				\
	} @catch (exception *e) {			\
		puts("CAUGHT! Error string was:");	\
		puts([[e string] cString]);		\
		puts("Resuming...");			\
	}

const char *str = "Hallo!";

#define TEST(type) \
	puts("Trying to add too much to an array...");			\
	a = [[type alloc] initWithItemSize: 4096];			\
	CATCH_EXCEPTION([a addNItems: SIZE_MAX				\
			  fromCArray: NULL],				\
	    OFOutOfRangeException)					\
									\
	puts("Trying to add something after that error...");		\
	p = [a allocMemoryWithSize: 4096];				\
	memset(p, 255, 4096);						\
	[a addItem: p];							\
	if (!memcmp([a lastItem], p, 4096))				\
		puts("[a lastItem] matches with p!");			\
	else {								\
		puts("[a lastItem] does not match p!");			\
		abort();						\
	}								\
	[a freeMemory: p];						\
									\
	puts("Adding more data...");					\
	q = [a allocMemoryWithSize: 4096];				\
	memset(q, 42, 4096);						\
	[a addItem: q];							\
	if (!memcmp([a lastItem], q, 4096))				\
		puts("[a lastItem] matches with q!");			\
	else {								\
		puts("[a lastItem] does not match q!");			\
		abort();						\
	}								\
	[a freeMemory: q];						\
									\
	puts("Adding multiple items at once...");			\
	p = [a allocMemoryWithSize: 8192];				\
	memset(p, 64, 8192);						\
	[a addNItems: 2							\
	  fromCArray: p];						\
	if (!memcmp([a lastItem], [a itemAtIndex: [a count] - 2], 4096) && \
	    !memcmp([a itemAtIndex: [a count] - 2], p, 4096))		\
		puts("[a lastItem], [a itemAtIndex: [a count] - 2] "	\
		    "and p match!");					\
	else {								\
		puts("[a lastItem], [a itemAtIndex: [a count] - 2] "	\
		    "and p do not match!");				\
		abort();						\
	}								\
	[a freeMemory: p];						\
									\
	i = [a count];							\
	puts("Removing 2 items...");					\
	[a removeNItems: 2];						\
	if ([a count] + 2 != i) {					\
		puts("[a count] + 2 != i!");				\
		abort();						\
	}								\
									\
	puts("Trying to remove more data than we added...");		\
	CATCH_EXCEPTION([a removeNItems: [a count] + 1],		\
	    OFOutOfRangeException);					\
									\
	puts("Trying to access an index that does not exist...");	\
	CATCH_EXCEPTION([a itemAtIndex: [a count]],			\
	    OFOutOfRangeException);					\
									\
	[a release];							\
									\
	puts("Creating new array and using it to build a string...");	\
	a = [[type alloc] initWithItemSize: 1];				\
									\
	for (i = 0; i < strlen(str); i++)				\
		[a addItem: (void*)&str[i]];				\
	[a addItem: ""];						\
									\
	if (!strcmp([a data], str))					\
		puts("Built string matches!");				\
	else {								\
		puts("Built string does not match!");			\
		abort();						\
	}								\
									\
	[a release];

int
main()
{
	id a;
	void *p, *q;
	size_t i;
	OFDataArray *x, *y;
	OFAutoreleasePool *pool;

	puts("== TESTING OFDataArray ==");
	TEST(OFDataArray)

	puts("== TESTING OFBigArray ==");
	TEST(OFBigDataArray)

	pool = [[OFAutoreleasePool alloc] init];
	x = [OFDataArray dataArrayWithItemSize: 1];
	y = [OFBigDataArray dataArrayWithItemSize: 1];

	if (![x isEqual: y]) {
		puts("FAIL 1!");
		return 1;
	}

	if ([x hash] != [y hash]) {
		puts("FAIL 2!");
		return 1;
	}

	[x addItem: "x"];
	if ([x isEqual: y]) {
		puts("FAIL 3!");
		return 1;
	}
	[pool releaseObjects];

	x = [OFDataArray dataArrayWithItemSize: 2];
	y = [OFBigDataArray dataArrayWithItemSize: 4];

	if ([x isEqual: y]) {
		puts("FAIL 4!");
		return 1;
	}
	[pool releaseObjects];

	x = [OFDataArray dataArrayWithItemSize: 1];
	[x addNItems: 3
	  fromCArray: "abc"];
	y = [x copy];
	if ([x compare: y]) {
		puts("FAIL 5!");
		return 1;
	}

	[y addItem: "de"];
	if ([x compare: y] != -100) {
		puts("FAIL 6!");
		return 1;
	}

	if ([y hash] != 0xCD8B6206) {
		puts("FAIL 7!");
		return 1;
	}
	[pool release];

	return 0;
}
