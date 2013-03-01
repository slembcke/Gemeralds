//
//  FlipperSprite.m
//  Gemeralds
//
//  Created by Scott Lembcke on 2/28/13.
//  Copyright 2013 Howling Moon Software. All rights reserved.
//

#import "FlipperSprite.h"
#import "PinballLayer.h"

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

-(PinballLayer *)pinballLayer
{
	for(CCNode *node = self.parent;; node = node.parent){
		if([node isKindOfClass:[PinballLayer class]]){
			return (id)node;
		}
	}
	
	@throw [NSException exceptionWithName:@"PinballLayerError" reason:@"FlipperNode does not have a parent of type PinballLayer" userInfo:nil];
}

-(NSString *)group
{
	return @"table";
}

-(void)onEnter
{
	[super onEnter];
	
	[self.pinballLayer addFlipper:self];
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
	
	
	ChipmunkPivotJoint *pivot = [ChipmunkPivotJoint pivotJointWithBodyA:bodyA bodyB:bodyB anchr1:cpvzero anchr2:cpvzero];
	ChipmunkRotaryLimitJoint *limit = [ChipmunkRotaryLimitJoint rotaryLimitJointWithBodyA:bodyA bodyB:bodyB min:0 max:ACTUATOR_LIMIT];
	
	_actuator = [ChipmunkGearJoint gearJointWithBodyA:bodyA bodyB:bodyB phase:0.0f ratio:1.0f];
	_actuator.maxForce = ACTUATOR_FORCE;
	_actuator.maxBias = ACTUATOR_RATE;
	_actuator.errorBias = pow(1.0 - 0.9, 60.0);
	
	self.up = FALSE;
	
	return @[pivot, limit, _actuator];
}

-(void)setUp:(BOOL)up
{
	_actuator.phase = (up ? ACTUATOR_LIMIT : 0.0f);
}

@end
