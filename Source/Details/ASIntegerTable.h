//
//  ASIntegerTable.h
//  Texture
//
//  Copyright (c) 2017-present, Pinterest, Inc.  All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/ASBaseDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * An objective-C wrapper for unordered_map.
 */
AS_SUBCLASSING_RESTRICTED
@interface ASIntegerTable : NSObject <NSCopying>

/**
 * Creates an integer table containing the mappings across the specified update.
 *
 * If oldCount is 0, returns the empty table.
 * If deleted and inserted are empty, returns the identity table.
 */
+ (ASIntegerTable *)tableWithMappingForOldCount:(NSInteger)oldCount
                                        deleted:(NSIndexSet *)deleted
                                       inserted:(NSIndexSet *)inserted;

/**
 * A singleton table that maps each integer to itself. Its reverse table is itself.
 */
@property (class, atomic, readonly) ASIntegerTable *identityTable;

/**
 * A singleton table that returns NSNotFound for all keys. Its reverse table is itself.
 */
@property (class, atomic, readonly) ASIntegerTable *emptyTable;

/**
 * Retrieves the integer for a given key, or NSNotFound if the key is not found.
 *
 * @param key A key to lookup the value for.
 */
- (NSInteger)integerForKey:(NSInteger)key;

/**
 * Create and return a table with the reverse mapping.
 */
- (ASIntegerTable *)reverseTable;

@end

NS_ASSUME_NONNULL_END
