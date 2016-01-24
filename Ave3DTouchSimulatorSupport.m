/*
 The MIT License (MIT)
 
 Copyright (c) 2015 Andreas Verhoeven (ave@aveapps.com)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
*/

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

/*
 This file simulates force touch in the simulator by doing dangerous runtime
 trickery. In short, it overrides -[UITouch _unclampedForce] to return
 a simulated force value in THIS APP ONLY.
 
 To increase the force until the peek view shows, hold down the COMMAND key while making touches.
 To increase the force further until the view is popped, hold down the CONTROL key as well.
 To slow down the increase of force, hold down the SHIFT key.
 
 */

#if TARGET_IPHONE_SIMULATOR

// KEY CONFIG
static NSInteger const keyCodeSimulateForce = 227; // command (starts force simulation for 'peek')
static NSInteger const keyCodeExtraForce = 224; // control (increases force to trigger the 'pop')
static NSInteger const keyCodeSlowDown = 225; // shift (slows down the increase in force)

// SPEED CONFIG
static CGFloat const smallForceIncrements = 0.4;  // if the command key is down, we add this much force per interval (or substract when the key is released)
static CGFloat const maximumPossibleForce = 10.0; // the maximum amount of force for the normal peek gesture
static CGFloat const largeForceIncrements = 10.0; // how much to increase extra applied force for the 'pop' gesture
static CGFloat const maximumExtraForceForPop = 100.0; // the maximum force for the 'pop' gesture
static CGFloat const slowDownFactor = 0.2; // if the shift key is held, force added is multiplied by this factor

// how quick the timer automatically increases/decreases the simulated force
static NSTimeInterval const adjustForceAutomaticallyTimeInterval = 0.01;

// keeps track of how much force we simulate
static CGFloat simulatedForce = 0.0;

// variables for the automatic increase/decrease of force
static NSTimer* timer = nil;
static UIEvent* lastTouchesEvent = nil;
static BOOL shouldIncreaseForce = NO;
static BOOL shouldApplyExtraForce = NO;
static BOOL shouldSlowDownIncreaseInForce = NO;


#pragma mark - Private UIKit Methods

@interface UITouch (Ave)
-(void)setPhase:(UITouchPhase)phase;
-(void)setTimestamp:(NSTimeInterval)timestamp;

-(CGFloat)_unclampedForce;
-(CGFloat)maximumPossibleForce;
-(BOOL)_supportsForce;

@end

@interface UIDevice (Ave)
-(BOOL)_supportsForceTouch;
@end


@interface UITouchesEvent
-(void)_clearTouches;
-(void)_addTouch:(UITouch*)touch forDelayedDelivery:(BOOL)val;
@end

@interface UIApplication (Ave)
-(void)handleKeyUIEvent:(id)event;
-(UITouchesEvent*)_touchesEvent;
@end

@interface UIPhysicalKeyboardEvent
-(NSUInteger)_keyCode;
-(BOOL)_isKeyDown;
@end



#pragma mark - Swizzling Helpers

static IMP AveReplaceInstanceMethod(Class class, SEL sel, id block)
{
	Method method = class_getInstanceMethod(class, sel);
	IMP newIMP = imp_implementationWithBlock(block);
	
	if(class_addMethod(class, sel, newIMP, method_getTypeEncoding(method)))
		return method_getImplementation(method);
	else
		return method_setImplementation(method, newIMP);
}

#pragma mark - UIApplicationHelper

@implementation UIApplication (AveTimer)

-(void)ave_sendFakeTouches
{
	// fakes resending force touches by replacing all touches
	// with "new" PhaseMoved touches, so the peek/pop gestures
	// can do their magic.
	
	NSSet* touches = [[lastTouchesEvent allTouches] copy];
	if(nil == touches)
		return;

	UITouchesEvent* event = [self _touchesEvent];
	[event _clearTouches];
	for (UITouch* touch in touches)
	{
		// we don't add ended or cancelled touches, since they should
		// no longer exist.
		if(touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled)
		{
			// set the touches to 'moved', so they get recognized
			// and reset the uptime.
			[touch setPhase:UITouchPhaseMoved];
			[touch setTimestamp:[[NSProcessInfo processInfo] systemUptime]];
			[event _addTouch:touch forDelayedDelivery:NO];
		}
	}
	
	[self sendEvent:(id)event];
}


-(void)ave_startTimer
{
	[timer invalidate];
	timer = [NSTimer timerWithTimeInterval:adjustForceAutomaticallyTimeInterval target:self selector:@selector(ave_timerFired:) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)ave_killTimer
{
	[timer invalidate];
	timer = nil;
}

-(void)ave_timerFired:(id)sender
{
	CGFloat factor = shouldSlowDownIncreaseInForce ? slowDownFactor : 1.0;
	if(shouldIncreaseForce == YES)
	{
		// increase the force by a small amount
		simulatedForce += smallForceIncrements * factor;
		
		if(simulatedForce >= maximumPossibleForce)
		{
			// if we are at the maximum amount, add some more amount, only if the 'pop' button (control)
			// is hit. We need that, because 'pop' is recognized by applying extra force above the
			// normal maximum.
			if(shouldApplyExtraForce == YES)
				simulatedForce = MAX(maximumExtraForceForPop, simulatedForce + largeForceIncrements * factor);
			else
				simulatedForce = maximumPossibleForce;
		}
	}
	else
	{
		// decrease the force slowly if the 'command' key is not held.
		simulatedForce -= smallForceIncrements * factor;
		if(simulatedForce <= 0.0)
		{
			[self ave_killTimer];
		}
	}
	
	[self ave_sendFakeTouches];
}
@end


#pragma mark - BootsTrap

__attribute__((constructor)) static void Ave3DTouchSimulatorSupportInitialize()
{
	// _unclampedForce is used by UIKit to detect the "pop" as well as regular force value.
	// we return our own simulatedForce.
	AveReplaceInstanceMethod([UITouch class], @selector(_unclampedForce), ^CGFloat(UITouch* obj){
		return simulatedForce;
	});
	
	// used by the framework to detect the "pop". A value larger than maximumPossibleForce triggers
	// a "pop".
	AveReplaceInstanceMethod([UITouch class], @selector(maximumPossibleForce), ^CGFloat(UITouch* obj){
		return maximumPossibleForce;
	});
	
	// used by the framework to see if force is supported
	AveReplaceInstanceMethod([UITouch class], @selector(_supportsForce), ^BOOL(UITouch* obj){
		return YES;
	});
	
	// used everywhere to see if this device supports force, we fake it, so we return 0.
	AveReplaceInstanceMethod([UITraitCollection class], @selector(forceTouchCapability), ^UIForceTouchCapability(UITraitCollection* obj){
		return UIForceTouchCapabilityAvailable;
	});
	
	// used in some places by UIKit.
	AveReplaceInstanceMethod([UIDevice class], @selector(_supportsForceTouch), ^BOOL(UIDevice* obj){
		return YES;
	});
	
	// We override sendEvent: to detect if all touches stopped, if so, we stop our simulated force as well.
	__block IMP originalSendEvent = AveReplaceInstanceMethod([UIApplication class], @selector(sendEvent:), ^(UIApplication* app, UIEvent* event){
		
		if(event.type == UIEventTypeTouches)
		{
			// keep track of the last Touches Event, so we know when we're not touching.
			lastTouchesEvent = event;
			
			// if all touches have ended/cancelled, the touch sequence is over.
			BOOL shouldStop = YES;
			for(UITouch* touch in event.allTouches)
			{
				if(touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled)
					shouldStop = NO;
			}
		
			if(shouldStop == YES)
			{
				// let's stop simulating force as well
				lastTouchesEvent = nil;
				[app ave_killTimer];
				simulatedForce = 0.0;
			}
		}
		
		((void (*)(id, SEL, UIEvent*))originalSendEvent)(app, @selector(sendEvent:), event);
	});
	
	// we override the internal handleKeyUIEvent: so we can detect command and control key presses
	__block IMP originalHandleKeyUIEvent = AveReplaceInstanceMethod([UIApplication class], @selector(handleKeyUIEvent:), ^(UIApplication* app, UIPhysicalKeyboardEvent* event){
		
		if(event._keyCode == keyCodeSimulateForce)
		{
			if(shouldIncreaseForce != event._isKeyDown)
			{
				// when the "command"-key state changes, we start a timer that
				// increases/reduces the simulatedForce depending on the start.
				shouldIncreaseForce = event._isKeyDown;
				[app ave_startTimer];
			}
		}
		else if(event._keyCode == keyCodeExtraForce)
		{
			// when the "control" key is down, we simulate extra force
			// for the pop gesture.
			shouldApplyExtraForce = event._isKeyDown;
		}
		else if(event._keyCode == keyCodeSlowDown)
		{
			// when the "shift" key is down, we slow down the force increase
			shouldSlowDownIncreaseInForce = event._isKeyDown;
		}
		
		((void (*)(id, SEL, UIPhysicalKeyboardEvent*))originalHandleKeyUIEvent)(app, @selector(handleKeyUIEvent:), event);
	});
};

#endif//TARGET_IPHONE_SIMULATOR
