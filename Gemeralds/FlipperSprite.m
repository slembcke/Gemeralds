/* Copyright (c) 2013 Scott Lembcke and Howling Moon Software
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


#import "FlipperSprite.h"
#import "PinballLayer.h"

#import "SimpleAudioEngine.h"

#define ACTUATOR_RATE 10.0f
#define ACTUATOR_LIMIT 0.7f
#define ACTUATOR_FORCE 1e9f

@implementation FlipperSprite {
	ChipmunkGearJoint *_actuator;
}

-(id)init
{
	if((self = [super init])){
		self.friction = 0.8;
		self.elasticity = 0.3;
	}
	
	return self;
}

-(NSString *)group
{
	return @"table";
}

-(void)onEnter
{
	[super onEnter];
	
	[[PinballLayer pinballLayer:self] addFlipper:self];
}

-(NSArray *)setupExtras
{
	ChipmunkBody *bodyA = self.chipmunkBody;
	ChipmunkBody *bodyB = [ChipmunkBody staticBody];
	bodyB.pos = bodyA.pos;
	
	// Swap the bodies for a left flipper so the rotation math works out the same way.
	if(self.leftFlipper){
		id tmp = bodyA;
		bodyA = bodyB;
		bodyB = tmp;
	}
	
	// The pivot and angular limit joints are straight forward enough.
	ChipmunkPivotJoint *pivot = [ChipmunkPivotJoint pivotJointWithBodyA:bodyA bodyB:bodyB anchr1:cpvzero anchr2:cpvzero];
	ChipmunkRotaryLimitJoint *limit = [ChipmunkRotaryLimitJoint rotaryLimitJointWithBodyA:bodyA bodyB:bodyB min:0 max:ACTUATOR_LIMIT];
	
	// This part is a little fancier. We are animating the joint properties of a gear joint for the flipper solenoid.
	// By changing the phase of the gear joint, it's forced to correct itself forcibly.
	_actuator = [ChipmunkGearJoint gearJointWithBodyA:bodyA bodyB:bodyB phase:0.0f ratio:1.0f];
	// The maximum angular rate and force are fairly straightforward.
	_actuator.maxForce = ACTUATOR_FORCE;
	_actuator.maxBias = ACTUATOR_RATE;
	// The error bias describes how quickly the joint tries to correct itself.
	// 0.0 means that the full error should be corrected immediately in the next step.
	// Normally it's much lower than that to keep jointed configurations of bodies stable.
	_actuator.errorBias = 0.0;
	
	self.up = FALSE;
	
	return @[pivot, limit, _actuator];
}

-(void)setUp:(BOOL)up
{
	_actuator.phase = (up ? ACTUATOR_LIMIT : 0.0f);
	
	if(up){
		[[SimpleAudioEngine sharedEngine] playEffect:@"flip-up.caf"];
	} else {
		[[SimpleAudioEngine sharedEngine] playEffect:@"flip-down.caf"];
	}
}

@end
