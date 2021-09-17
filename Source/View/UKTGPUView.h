//
//  UKTGPUView.h
//  UIKit Toolbox
//
//  Created by Stevo on 4/1/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

#pragma once

#import "CGPU.h"
#import "TimeAndDate.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTGPUView
@protocol UKTGPUView

// MARK: Properties
@property (nonatomic, readonly)	CGPU&	gpu;

@property (nonatomic, strong)	void	(^touchesBeganProc)(NSSet<UITouch*>* touches, UIEvent* event);
@property (nonatomic, strong)	void	(^touchesMovedProc)(NSSet<UITouch*>* touches, UIEvent* event);
@property (nonatomic, strong)	void	(^touchesEndedProc)(NSSet<UITouch*>* touches, UIEvent* event);
@property (nonatomic, strong)	void	(^touchesCancelledProc)(NSSet<UITouch*>* touches, UIEvent* event);

@property (nonatomic, strong)	void	(^motionBeganProc)(UIEventSubtype eventSubtype, UIEvent* event);
@property (nonatomic, strong)	void	(^motionEndedProc)(UIEventSubtype eventSubtype, UIEvent* event);

@property (nonatomic, strong)	void	(^periodicProc)(UniversalTimeInterval outputTime);

// MARK: Instance methods
- (void) installPeriodic;
- (void) removePeriodic;

@end

NS_ASSUME_NONNULL_END
