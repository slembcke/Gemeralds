//
//  SpaceNode.m
//  Gemeralds
//
//  Created by Scott Lembcke on 12/19/12.
//  Copyright 2012 Howling Moon Software. All rights reserved.
//

#import "SpaceNode.h"
#import <CoreMotion/CoreMotion.h>

#import "SimpleAudioEngine.h"

const cpFloat Gravity = 600.0;

@implementation SpaceNode {
	CCPhysicsDebugNode *_debugNode;
	
	ccTime _accumulator;
	CMMotionManager *_motion;
	
	NSMutableDictionary *_identifiers;
}

-(id)init
{
	if((self = [super init])){
		_space = [[ChipmunkSpace alloc] init];
		_space.gravity = cpv(0, -Gravity);
		
		_identifiers = [NSMutableDictionary dictionary];
		[_space addCollisionHandler:self typeA:[self identifierForKey:@"bumper"] typeB:[self identifierForKey:@"ball"]
			begin:nil preSolve:@selector(bumperPreSolve:space:) postSolve:nil separate:nil
		];
		
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
//#if !TARGET_IPHONE_SIMULATOR
//	CMAcceleration accel = _motion.accelerometerData.acceleration;
//	_space.gravity = cpvmult(cpv(-accel.y, accel.x), Gravity);
//#endif
	
	// Might as well use a small timestep since the simulation is so simple.
  ccTime fixed_dt = 1.0/(ccTime)180.0;
  
  // Add the current dynamic timestep to the accumulator.
  // Clamp the timestep though to prevent really long frames from causing a large backlog of fixed timesteps to be run.
  _accumulator += MIN(dt, 0.1);
  // Subtract off fixed-sized chunks of time from the accumulator and step
  while(_accumulator > fixed_dt){
    [self tick:fixed_dt];
    _accumulator -= fixed_dt;
  }
}

-(BOOL)bumperPreSolve:(cpArbiter *)arb space:(ChipmunkSpace *)space
{
	CHIPMUNK_ARBITER_GET_BODIES(arb, bumper, ball);
	
	cpVect n = cpArbiterGetNormal(arb, 0);
	bumper.vel = cpvmult(n, 400.0f);
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"ding.caf"];
	
	return TRUE;
}

-(NSString *)identifierForKey:(NSString *)key
{
	if(key && _identifiers[key] == nil){
		_identifiers[key] = key;
	}
	
	NSLog(@"Returning %@ (%p)", _identifiers[key], _identifiers[key]);
	return _identifiers[key];
}

@end
