//----------------------------------------------------------------------------------------------------------------------
//	UKTMetalView.mm			©2020 Stevo Brock		All rights reserved.
//----------------------------------------------------------------------------------------------------------------------

#import "UKTMetalView.h"

#import "CMetalGPU.h"

//----------------------------------------------------------------------------------------------------------------------
// MARK: Local procs declaration

static	id<MTLDevice>				sGetDeviceProc(UKTMetalView* metalView);
static	id <CAMetalDrawable>		sGetCurrentDrawableProc(UKTMetalView* metalView);
static	MTLPixelFormat				sGetPixelFormatProc(UKTMetalView* metalView);
static	NSUInteger					sGetSampleCountProc(UKTMetalView* metalView);
static	MTLRenderPassDescriptor*	sGetCurrentRenderPassDescriptor(UKTMetalView* metalView);

//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------
// MARK: - UKTMetalView

@interface UKTMetalView ()

@property (nonatomic, assign)	CGPU*	gpuInternal;

@end

@implementation UKTMetalView

@synthesize touchesBeganProc;
@synthesize touchesMovedProc;
@synthesize touchesEndedProc;
@synthesize touchesCancelledProc;

@synthesize motionBeganProc;
@synthesize motionEndedProc;

@synthesize periodicProc;

// MARK: Lifecycle methods

//----------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithFrame:(CGRect) frame
{
	// Setup
	id<MTLDevice>	device = MTLCreateSystemDefaultDevice();

	self = [super initWithFrame:frame device:device];
	if (self != nil) {
		// Complete setup
		self.delegate = self;

		self.depthStencilPixelFormat = MTLPixelFormatDepth32Float;
#if defined(DEBUG)
		self.clearColor = MTLClearColorMake(0.5, 0.0, 0.25, 1.0);
#endif

		self.gpuInternal =
				new CGPU(
						SGPUProcsInfo((SGPUProcsInfo::GetDeviceProc) sGetDeviceProc,
								(SGPUProcsInfo::GetCurrentDrawableProc) sGetCurrentDrawableProc,
								(SGPUProcsInfo::GetPixelFormatProc) sGetPixelFormatProc,
								(SGPUProcsInfo::GetSampleCountProc) sGetSampleCountProc,
								(SGPUProcsInfo::GetCurrentRenderPassDescriptor) sGetCurrentRenderPassDescriptor,
								(__bridge void*) self));
	}

	return self;
}
//----------------------------------------------------------------------------------------------------------------------
- (instancetype) initWithCoder:(NSCoder*) coder
{
	// Setup
	self = [super initWithCoder:coder];
	if (self != nil) {
		// Complete setup
		self.device = MTLCreateSystemDefaultDevice();
		self.delegate = self;

		self.depthStencilPixelFormat = MTLPixelFormatDepth32Float;
#if defined(DEBUG)
		self.clearColor = MTLClearColorMake(0.5, 0.0, 0.25, 1.0);
#endif

		self.gpuInternal =
				new CGPU(
						SGPUProcsInfo((SGPUProcsInfo::GetDeviceProc) sGetDeviceProc,
								(SGPUProcsInfo::GetCurrentDrawableProc) sGetCurrentDrawableProc,
								(SGPUProcsInfo::GetPixelFormatProc) sGetPixelFormatProc,
								(SGPUProcsInfo::GetSampleCountProc) sGetSampleCountProc,
								(SGPUProcsInfo::GetCurrentRenderPassDescriptor) sGetCurrentRenderPassDescriptor,
								(__bridge void*) self));
	}

	return self;
}

// MARK: NSResponder methods

//----------------------------------------------------------------------------------------------------------------------
- (BOOL) canBecomeFirstResponder
{
	return YES;
}

//----------------------------------------------------------------------------------------------------------------------
- (void) touchesBegan:(NSSet<UITouch*>*) touches withEvent:(UIEvent*) event
{
	self.touchesBeganProc(touches, event);
}

//----------------------------------------------------------------------------------------------------------------------
- (void) touchesMoved:(NSSet<UITouch*>*) touches withEvent:(UIEvent*) event
{
	self.touchesMovedProc(touches, event);
}

//----------------------------------------------------------------------------------------------------------------------
- (void) touchesEnded:(NSSet<UITouch*>*) touches withEvent:(UIEvent*) event
{
	self.touchesEndedProc(touches, event);
}

//----------------------------------------------------------------------------------------------------------------------
- (void) touchesCancelled:(NSSet<UITouch*>*) touches withEvent:(UIEvent*) event
{
	self.touchesCancelledProc(touches, event);
}

//----------------------------------------------------------------------------------------------------------------------
- (void) motionBegan:(UIEventSubtype) eventSubtype withEvent:(UIEvent*) event
{
	self.motionBeganProc(eventSubtype, event);
}

//----------------------------------------------------------------------------------------------------------------------
- (void) motionEnded:(UIEventSubtype) eventSubtype withEvent:(UIEvent*) event
{
	self.motionEndedProc(eventSubtype, event);
}

// MARK: AKTGPUView methods

//----------------------------------------------------------------------------------------------------------------------
- (CGPU&) gpu
{
	return *self.gpuInternal;
}

//----------------------------------------------------------------------------------------------------------------------
- (void) installPeriodic
{
	self.paused = false;
}

//----------------------------------------------------------------------------------------------------------------------
- (void) removePeriodic
{
	self.paused = true;
}

// MARK: MTKViewDelegate methods

//----------------------------------------------------------------------------------------------------------------------
- (void) mtkView:(nonnull MTKView*) view drawableSizeWillChange:(CGSize) size
{
}

//----------------------------------------------------------------------------------------------------------------------
- (void) drawInMTKView:(nonnull MTKView*) view
{
	// Run lean
	@autoreleasepool {
		// Call periodic proc
		self.periodicProc(SUniversalTime::getCurrent() + 1.0 / (UniversalTimeInterval) self.preferredFramesPerSecond);
	}
}

@end

//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------
// MARK: - Local proc definitions

//----------------------------------------------------------------------------------------------------------------------
id<MTLDevice> sGetDeviceProc(UKTMetalView* metalView)
{
	return metalView.device;
}

//----------------------------------------------------------------------------------------------------------------------
id <CAMetalDrawable> sGetCurrentDrawableProc(UKTMetalView* metalView)
{
	return metalView.currentDrawable;
}

//----------------------------------------------------------------------------------------------------------------------
MTLPixelFormat sGetPixelFormatProc(UKTMetalView* metalView)
{
	return metalView.colorPixelFormat;
}

//----------------------------------------------------------------------------------------------------------------------
NSUInteger sGetSampleCountProc(UKTMetalView* metalView)
{
	return metalView.sampleCount;
}

//----------------------------------------------------------------------------------------------------------------------
MTLRenderPassDescriptor* sGetCurrentRenderPassDescriptor(UKTMetalView* metalView)
{
	return metalView.currentRenderPassDescriptor;
}
