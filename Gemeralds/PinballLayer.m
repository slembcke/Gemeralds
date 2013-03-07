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


#import "ObjectiveChipmunk.h"
#import "PinballLayer.h"
#import "FlipperSprite.h"

@implementation PinballLayer {
	NSMutableArray *_flippers;
	
	int _leftTouches, _rightTouches;
}

+(PinballLayer *)pinballLayer:(CCNode *)child
{
	for(CCNode *node = child.parent;; node = node.parent){
		if([node isKindOfClass:[PinballLayer class]]){
			return (id)node;
		}
	}
	
	@throw [NSException exceptionWithName:@"PinballLayerError" reason:@"Child does not have a parent of type PinballLayer" userInfo:nil];
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
	[super onEnter];
	[self scheduleUpdateWithPriority:-1];
}

-(void)update:(ccTime)dt
{
	CGFloat h = [CCDirector sharedDirector].winSize.height;
	CGFloat targetY = h/2.0f - self.followNode.position.y;
	
	CGFloat scroll = cpflerp(self.position.y, targetY, 1.0f - powf(0.1f, dt*5.0));
	self.position = ccp(0.0f, cpfclamp(scroll, h - self.contentSize.height, 0.0f));
}

// Mark: Input Methods

-(void)incrementLeft
{
	_leftTouches++;
	if(_leftTouches == 1){
//		NSLog(@"Left began");
		[self setLeftFlippers:TRUE to:TRUE];
	}
}

-(void)decrementLeft
{
	_leftTouches--;
	if(_leftTouches == 0){
//		NSLog(@"Left ended");
		[self setLeftFlippers:TRUE to:FALSE];
	}
}

-(void)incrementRight
{
	_rightTouches++;
	if(_rightTouches == 1){
//		NSLog(@"Right began");
		[self setLeftFlippers:FALSE to:TRUE];
	}
}

-(void)decrementRight
{
	_rightTouches--;
	if(_rightTouches == 0){
//		NSLog(@"Right ended");
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
	// Being careful about middle conditions here.
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

@end
