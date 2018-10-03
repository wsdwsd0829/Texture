//
//  ASConfigurationTests.m
//  Texture
//
//  Copyright (c) Pinterest, Inc.  All rights reserved.
//  Licensed under Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0
//

#import <XCTest/XCTest.h>
#import "ASTestCase.h"
#import "ASConfiguration.h"
#import "ASConfigurationDelegate.h"
#import "ASConfigurationInternal.h"

@interface ASConfigurationTests : ASTestCase <ASConfigurationDelegate>

@end

@implementation ASConfigurationTests {
  void (^onActivate)(ASConfigurationTests *self, ASExperimentalFeatures feature);
}

- (void)testExperimentalFeatureConfig
{
  // Set the config
  ASConfiguration *config = [[ASConfiguration alloc] initWithDictionary:nil];
  config.experimentalFeatures = ASExperimentalGraphicsContexts;
  config.delegate = self;
  [ASConfigurationManager test_resetWithConfiguration:config];
  
  // Set an expectation for a callback, and assert we only get one.
  XCTestExpectation *e = [self expectationWithDescription:@"Callbacks done."];
  e.expectedFulfillmentCount = 2;
  e.assertForOverFulfill = YES;
  onActivate = ^(ASConfigurationTests *self, ASExperimentalFeatures feature) {
    [e fulfill];
  };
  
  // Now activate the graphics experiment and expect it works.
  XCTAssertTrue(ASActivateExperimentalFeature(ASExperimentalGraphicsContexts));
  // We should get a callback here
  // Now activate text node and expect it fails.
  XCTAssertFalse(ASActivateExperimentalFeature(ASExperimentalTextNode));
  // But we should get another callback.
  [self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)textureDidActivateExperimentalFeatures:(ASExperimentalFeatures)feature
{
  if (onActivate) {
    onActivate(self, feature);
  }
}

- (void)testMappingNamesToFlags
{
  // Throw in a bad bit.
  ASExperimentalFeatures features = ASExperimentalGraphicsContexts |
                                    ASExperimentalTextNode |
                                    ASExperimentalInterfaceStateCoalescing |
                                    ASExperimentalUnfairLock |
                                    ASExperimentalLayerDefaults |
                                    ASExperimentalNetworkImageQueue |
                                    ASExperimentalCollectionTeardown |
                                    ASExperimentalFramesetterCache |
                                    ASExperimentalSkipClearData | (1 << 22);
  NSArray *expectedNames = @[@"exp_graphics_contexts",
                             @"exp_text_node",
                             @"exp_interface_state_coalesce",
                             @"exp_unfair_lock",
                             @"exp_infer_layer_defaults",
                             @"exp_network_image_queue",
                             @"exp_collection_teardown",
                             @"exp_framesetter_cache",
                             @"exp_skip_clear_data"];
  XCTAssertEqualObjects(expectedNames, ASExperimentalFeaturesGetNames(features));
}

- (void)testMappingFlagsFromNames
{
  // Throw in a bad name.
  NSArray *names = @[@"exp_graphics_contexts",
                     @"exp_text_node",
                     @"exp_interface_state_coalesce",
                     @"exp_unfair_lock",
                     @"exp_infer_layer_defaults",
                     @"exp_network_image_queue",
                     @"exp_collection_teardown",
                     @"exp_framesetter_cache",
                     @"exp_skip_clear_data",
                     @"__invalid_name"];
  ASExperimentalFeatures expected = ASExperimentalGraphicsContexts |
                                    ASExperimentalTextNode |
                                    ASExperimentalInterfaceStateCoalescing |
                                    ASExperimentalUnfairLock |
                                    ASExperimentalLayerDefaults |
                                    ASExperimentalNetworkImageQueue |
                                    ASExperimentalCollectionTeardown |
                                    ASExperimentalFramesetterCache |
                                    ASExperimentalSkipClearData;
  XCTAssertEqual(expected, ASExperimentalFeaturesFromArray(names));
}

- (void)testFlagMatchName
{
  NSArray *names = @[
    @"exp_graphics_contexts",
    @"exp_text_node",
    @"exp_interface_state_coalesce",
    @"exp_unfair_lock",
    @"exp_infer_layer_defaults",
    @"exp_network_image_queue",
    @"exp_collection_teardown",
    @"exp_framesetter_cache",
    @"exp_skip_clear_data"
  ];
  ASExperimentalFeatures features[] = {
    ASExperimentalGraphicsContexts,
    ASExperimentalTextNode,
    ASExperimentalInterfaceStateCoalescing,
    ASExperimentalUnfairLock,
    ASExperimentalLayerDefaults,
    ASExperimentalNetworkImageQueue,
    ASExperimentalCollectionTeardown,
    ASExperimentalFramesetterCache,
    ASExperimentalSkipClearData
  };
  for (NSInteger i = 0; i < names.count; i++) {
    XCTAssertEqual(features[i], ASExperimentalFeaturesFromArray(@[names[i]]));
  }
}

- (void)testNameMatchFlag {
  NSArray *names = @[
    @"exp_graphics_contexts",
    @"exp_text_node",
    @"exp_interface_state_coalesce",
    @"exp_unfair_lock",
    @"exp_infer_layer_defaults",
    @"exp_network_image_queue",
    @"exp_collection_teardown",
    @"exp_framesetter_cache",
    @"exp_skip_clear_data"
  ];
  ASExperimentalFeatures features[] = {
    ASExperimentalGraphicsContexts,
    ASExperimentalTextNode,
    ASExperimentalInterfaceStateCoalescing,
    ASExperimentalUnfairLock,
    ASExperimentalLayerDefaults,
    ASExperimentalNetworkImageQueue,
    ASExperimentalCollectionTeardown,
    ASExperimentalFramesetterCache,
    ASExperimentalSkipClearData
  };

  for (NSInteger i = 0; i < names.count; i++) {
    XCTAssertEqualObjects(@[names[i]], ASExperimentalFeaturesGetNames(features[i]));
  }
}

@end
