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

+(SpaceNode *)spaceNode:(CCNode *)child;
{
	for(CCNode *node = child.parent;; node = node.parent){
		if([node isKindOfClass:[SpaceNode class]]){
			return (id)node;
		}
	}
	
	@throw [NSException exceptionWithName:@"SpaceNodeError" reason:@"Child does not have a parent of type SpacenNode" userInfo:nil];
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
		_debugNode.visible = TRUE;
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
	// This avoids synchronization issues without fancy interpolation/extrapolation as well.
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
	
	// So this is sort of a hack.
	// There will be a feature to better support this in the future.
	// Basically, we want the collision to think that the bumper is moving, even though it's a static body.
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
