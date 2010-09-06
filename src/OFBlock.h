/*
 * Copyright (c) 2008 - 2010
 *   Jonathan Schleifer <js@webkeks.org>
 *
 * All rights reserved.
 *
 * This file is part of ObjFW. It may be distributed under the terms of the
 * Q Public License 1.0, which can be found in the file LICENSE included in
 * the packaging of this file.
 */

#import "objfw-defs.h"

#ifdef OF_OBJFW_RUNTIME
# import <objfw-rt.h>
#else
# import <objc/objc.h>
#endif

typedef struct __of_block_literal {
	Class isa;
	int flags;
	int reserved;
	void (*invoke)(void *, ...);
	struct __of_block_descriptor {
		unsigned long reserved;
		unsigned long size;
		void (*copy_helper)(void *dest, void *src);
		void (*dispose_helper)(void *src);
		const char *signature;
	} *descriptor;
} of_block_literal_t;

typedef struct __of_block_byref {
	Class isa;
	struct __of_block_byref *forwarding;
	int flags;
	int size;
	void (*byref_keep)(void *dest, void *src);
	void (*byref_dispose)(void*);
} of_block_byref_t;

enum {
	OF_BLOCK_HAS_COPY_DISPOSE = (1 << 25),
	OF_BLOCK_HAS_CTOR	  = (1 << 26),
	OF_BLOCK_IS_GLOBAL	  = (1 << 28),
	OF_BLOCK_HAS_STRET	  = (1 << 29),
	OF_BLOCK_HAS_SIGNATURE	  = (1 << 30),
};

enum {
	OF_BLOCK_FIELD_IS_OBJECT =   3,
	OF_BLOCK_FIELD_IS_BLOCK	 =   7,
	OF_BLOCK_FIELD_IS_BYREF	 =   8,
	OF_BLOCK_FIELD_IS_WEAK	 =  16,
	OF_BLOCK_BYREF_CALLER	 = 128,
};

@interface OFBlock
{
	Class isa;
}

- copy;
- (void)release;
- autorelease;
@end

extern of_block_literal_t* Block_copy(of_block_literal_t*);
extern void Block_release(of_block_literal_t*);