//----------------------------------------------------------------------------------------------------------------------
//	UKTMetalView.h			©2020 Stevo Brock		All rights reserved.
//----------------------------------------------------------------------------------------------------------------------

#pragma once

#import "UKTGPUView.h"

#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTMetalView

@interface UKTMetalView : MTKView <UKTGPUView, MTKViewDelegate>

// MARK: Lifecycle methods

@end

NS_ASSUME_NONNULL_END
