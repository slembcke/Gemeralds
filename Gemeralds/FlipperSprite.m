//
//  FlipperSprite.m
//  Gemeralds
//
//  Created by Scott Lembcke on 2/28/13.
//  Copyright 2013 Howling Moon Software. All rights reserved.
//

#import "FlipperSprite.h"
#import "PinballLayer.h"

#define ACTUATOR_RATE 20.0f
#define ACTUATOR_LIMIT 0.7f
#define ACTUATOR_FORCE 1e10f

@implementation FlipperSprite {
	ChipmunkSimpleMotor *_actuator;
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
	[self.pinballLayer addFlipper:self];
	[super onEnter];
}

-(NSArray *)setupExtras
{
	ChipmunkBody *body = self.chipmunkBody;
	
	ChipmunkBody *staticBody = [ChipmunkBody staticBody];
	staticBody.pos = body.pos;
	
	ChipmunkPivotJoint *pivot = [ChipmunkPivotJoint pivotJointWithBodyA:body bodyB:staticBody anchr1:cpvzero anchr2:cpvzero];
	ChipmunkRotaryLimitJoint *limit = [ChipmunkRotaryLimitJoint rotaryLimitJointWithBodyA:body bodyB:staticBody min:0 max:0];
	
	if(self.leftFlipper){
		limit.min = -ACTUATOR_LIMIT;
	} else {
		limit.max =  ACTUATOR_LIMIT;
	}
	
	_actuator = [ChipmunkSimpleMotor simpleMotorWithBodyA:body bodyB:staticBody rate:0.0f];
	_actuator.maxForce = ACTUATOR_FORCE;
	self.up = FALSE;
	
	return @[pivot, limit, _actuator];
}

-(void)setUp:(BOOL)up
{
	_actuator.rate = ACTUATOR_RATE*(self.leftFlipper^up ? -1.0f : 1.0f);
}

@end
