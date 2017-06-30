//
//  ASIntegerTable.m
//  Texture
//
//  Copyright (c) 2017-present, Pinterest, Inc.  All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//

#import "ASIntegerTable.h"
#import <unordered_map>
#import <NSIndexSet+ASHelpers.h>
#import <AsyncDisplayKit/ASObjectDescriptionHelpers.h>

/**
 * This is just a friendly Objective-C interface to unordered_map<NSInteger, NSInteger>
 */
@interface ASIntegerTable () <ASDescriptionProvider>
@end

@implementation ASIntegerTable {
  std::unordered_map<NSInteger, NSInteger> _map;
  BOOL _isIdentity;
  BOOL _isEmpty;
}

#pragma mark - Singleton

+ (ASIntegerTable *)identityTable
{
  static ASIntegerTable *identityTable;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    identityTable = [[ASIntegerTable alloc] init];
    identityTable->_isIdentity = YES;
  });
  return identityTable;
}

+ (ASIntegerTable *)emptyTable
{
  static ASIntegerTable *emptyTable;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    emptyTable = [[ASIntegerTable alloc] init];
    emptyTable->_isEmpty = YES;
  });
  return emptyTable;
}

+ (ASIntegerTable *)tableWithMappingForOldCount:(NSInteger)oldCount deleted:(NSIndexSet *)deletions inserted:(NSIndexSet *)insertions
{
  if (oldCount == 0) {
    return ASIntegerTable.emptyTable;
  }

  if (deletions.count == 0 && insertions.count == 0) {
    return ASIntegerTable.identityTable;
  }

  ASIntegerTable *result = [[ASIntegerTable alloc] init];
  // Start with the old indexes
  NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, oldCount)];

  // Descending order, shift deleted ranges left
  [deletions enumerateRangesWithOptions:NSEnumerationReverse usingBlock:^(NSRange range, BOOL * _Nonnull stop) {
    [indexes shiftIndexesStartingAtIndex:NSMaxRange(range) by:-range.length];
  }];

  // Ascending order, shift inserted ranges right
  [insertions enumerateRangesUsingBlock:^(NSRange range, BOOL * _Nonnull stop) {
    [indexes shiftIndexesStartingAtIndex:range.location by:range.length];
  }];

  __block NSInteger oldIndex = 0;
  [indexes enumerateRangesUsingBlock:^(NSRange range, BOOL * _Nonnull stop) {
    // Note we advance oldIndex unconditionally, not newIndex
    for (NSInteger newIndex = range.location; newIndex < NSMaxRange(range); oldIndex++) {
      if ([deletions containsIndex:oldIndex]) {
        // index was deleted, do nothing, just let oldIndex advance.
      } else {
        // assign the next index for this item.
        result->_map[oldIndex] = newIndex++;
      }
    }
  }];
  return result;
}

- (NSInteger)integerForKey:(NSInteger)key
{
  if (_isIdentity) {
    return key;
  } else if (_isEmpty) {
    return NSNotFound;
  }

  auto result = _map.find(key);
  return result != _map.end() ? result->second : NSNotFound;
}

- (ASIntegerTable *)reverseTable
{
  if (_isIdentity || _isEmpty) {
    return self;
  }

  auto result = [[ASIntegerTable alloc] init];
  for (auto it = _map.begin(); it != _map.end(); it++) {
    result->_map[it->second] = it->first;
  }
  return result;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}

#pragma mark - Description

- (NSMutableArray<NSDictionary *> *)propertiesForDescription
{
  NSMutableArray *result = [NSMutableArray array];

  if (_isIdentity) {
    [result addObject:@{ @"map": @"<identity>" }];
  } else if (_isEmpty) {
    [result addObject:@{ @"map": @"<empty>" }];
  } else {
    // { 1->2 3->4 5->6 }
    NSMutableString *str = [NSMutableString string];
    for (auto it = _map.begin(); it != _map.end(); it++) {
      [str appendFormat:@" %zd->%zd", it->first, it->second];
    }
    // Remove leading space
    if (str.length > 0) {
      [str deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    [result addObject:@{ @"map": str }];
  }

  return result;
}

- (NSString *)description
{
  return ASObjectDescriptionMakeWithoutObject([self propertiesForDescription]);
}

@end
