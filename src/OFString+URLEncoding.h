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

#import "OFString.h"

extern int _OFString_URLEncoding_reference;

/**
 * \brief A category which provides URL encoding and decoding.
 */
@interface OFString (URLEncoding)
/**
 * Encodes a string for use in a URL.
 *
 * \return A new autoreleased string
 */
- (OFString*)stringByURLEncoding;

/**
 * Decodes a string used in a URL.
 *
 * \return A new autoreleased string
 */
- (OFString*)stringByURLDecoding;
@end