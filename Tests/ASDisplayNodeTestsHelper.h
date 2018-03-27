//
//  ASDisplayNodeTestsHelper.h
//  Texture
//
//  Copyright (c) 2014-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the /ASDK-Licenses directory of this source tree. An additional
//  grant of patent rights can be found in the PATENTS file in the same directory.
//
//  Modifications to this file made after 4/13/2017 are: Copyright (c) 2017-present,
//  Pinterest, Inc.  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/ASDimension.h>

@class ASCATransactionQueue, ASDisplayNode;

typedef BOOL (^as_condition_block_t)(void);

ASDISPLAYNODE_EXTERN_C_BEGIN

BOOL ASDisplayNodeRunRunLoopUntilBlockIsTrue(as_condition_block_t block);

void ASDisplayNodeSizeToFitSize(ASDisplayNode *node, CGSize size);
void ASDisplayNodeSizeToFitSizeRange(ASDisplayNode *node, ASSizeRange sizeRange);
void ASCATransactionQueueWait(ASCATransactionQueue *q); // nil means shared queue

ASDISPLAYNODE_EXTERN_C_END
