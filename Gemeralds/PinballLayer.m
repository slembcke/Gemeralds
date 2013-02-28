//
//  PinballLayer.m
//  Gemeralds
//
//  Created by Scott Lembcke on 2/28/13.
//  Copyright 2013 Howling Moon Software. All rights reserved.
//

#import "ObjectiveChipmunk.h"
#import "PinballLayer.h"
#import "FlipperSprite.h"

@implementation PinballLayer {
	NSMutableArray *_flippers;
	
	int _leftTouches, _rightTouches;
}

-(id)init
{
	if((self = [super init])){
		_flippers = [NSMutableArray array];
		
		self.touchEnabled = TRUE;
		self.touchMode = kCCTouchesOneByOne;
	}
	
	return self;
}

-(void)addFlipper:(FlipperSprite *)flipper
{
	[_flippers addObject:flipper];
}

-(void)setLeftFlippers:(BOOL)left to:(BOOL)up
{
	for(FlipperSprite *flipper in _flippers){
		if(flipper.leftFlipper == left){
			flipper.up = up;
		}
	}
}

-(void)onEnter
{
	[self scheduleUpdate];
	[super onEnter];
}

-(void)incrementLeft
{
	_leftTouches++;
	if(_leftTouches == 1){
		NSLog(@"Left began");
		[self setLeftFlippers:TRUE to:TRUE];
	}
}

-(void)decrementLeft
{
	_leftTouches--;
	if(_leftTouches == 0){
		NSLog(@"Left ended");
		[self setLeftFlippers:TRUE to:FALSE];
	}
}

-(void)incrementRight
{
	_rightTouches++;
	if(_rightTouches == 1){
		NSLog(@"Right began");
		[self setLeftFlippers:FALSE to:TRUE];
	}
}

-(void)decrementRight
{
	_rightTouches--;
	if(_rightTouches == 0){
		NSLog(@"Right ended");
		[self setLeftFlippers:FALSE to:FALSE];
	}
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint p = [touch locationInView:touch.view];
	CGFloat hw = [CCDirector sharedDirector].winSize.width/2.0;
	
	if(p.x < hw){
		[self incrementLeft];
	} else {
		[self incrementRight];
	}
	
	return TRUE;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint p = [touch locationInView:touch.view];
	CGPoint pp = [touch previousLocationInView:touch.view];
	CGFloat hw = [CCDirector sharedDirector].winSize.width/2.0;
	
	// Check if the touch changed sides.
	// Being careful about middle conditions.
	if((p.x - hw)*(pp.x - hw) <= 0.0f){
		if(pp.x < hw){
			[self decrementLeft];
		} else if(pp.x > hw){
			[self decrementRight];
		}
		
		if(p.x < hw){
			[self incrementLeft];
		} else if(p.x > hw){
			[self incrementRight];
		}
	}
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint p = [touch locationInView:touch.view];
	CGFloat hw = [CCDirector sharedDirector].winSize.width/2.0;
	
	if(p.x < hw){
		[self decrementLeft];
	} else {
		[self decrementRight];
	}
}

-(void)update:(ccTime)delta
{
	
}

@end
