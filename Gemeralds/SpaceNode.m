//
//  SpaceNode.m
//  Gemeralds
//
//  Created by Scott Lembcke on 12/19/12.
//  Copyright 2012 Howling Moon Software. All rights reserved.
//

#import "SpaceNode.h"
#import <CoreMotion/CoreMotion.h>

const cpFloat Gravity = 300.0;

@implementation SpaceNode {
	CCPhysicsDebugNode *_debugNode;
	
	ccTime _accumulator;
	CMMotionManager *_motion;
}

-(id)init
{
	if((self = [super init])){
		_space = [[ChipmunkSpace alloc] init];
		_space.gravity = cpv(0, -Gravity);
		
		_debugNode = [CCPhysicsDebugNode debugNodeForChipmunkSpace:_space];
		_debugNode.visible = FALSE;
		[self addChild:_debugNode z:1000];
	}
	
	return self;
}

-(void)onEnter
{
	[super onEnter];
	
	[self scheduleUpdate];
	_motion = [[CMMotionManager alloc] init];
	_motion.accelerometerUpdateInterval = 1.0/60.0;
	[_motion startAccelerometerUpdates];
}

-(void)onExit
{
	[super onExit];
	_motion = nil;
}

-(void)tick:(ccTime)dt
{
	[_space step:dt];
}

-(void)update:(ccTime)dt
{
#if !TARGET_IPHONE_SIMULATOR
	CMAcceleration accel = _motion.accelerometerData.acceleration;
	_space.gravity = cpvmult(cpv(-accel.y, accel.x), Gravity);
#endif
	
  ccTime fixed_dt = 1.0/(ccTime)60.0;
  
  // Add the current dynamic timestep to the accumulator.
  // Clamp the timestep though to prevent really long frames from causing a large backlog of fixed timesteps to be run.
  _accumulator += MIN(dt, 0.1);
  // Subtract off fixed-sized chunks of time from the accumulator and step
  while(_accumulator > fixed_dt){
    [self tick:fixed_dt];
    _accumulator -= fixed_dt;
  }
}

@end
