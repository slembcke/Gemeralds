//
//  Pinball.m
//  Gemeralds
//
//  Created by Scott Lembcke on 3/1/13.
//  Copyright 2013 Howling Moon Software. All rights reserved.
//

#import "Pinball.h"
#import "PinballLayer.h"


@implementation Pinball

-(PinballLayer *)pinballLayer
{
	for(CCNode *node = self.parent;; node = node.parent){
		if([node isKindOfClass:[PinballLayer class]]){
			return (id)node;
		}
	}
	
	@throw [NSException exceptionWithName:@"PinballLayerError" reason:@"FlipperNode does not have a parent of type PinballLayer" userInfo:nil];
}

-(void)onEnter
{
	[super onEnter];
	
	self.pinballLayer.followNode = self;
	[self scheduleUpdate];
}

-(void)update:(ccTime)dt
{
	ChipmunkBody *body = self.chipmunkBody;
	
	if(body.pos.y < -30.0f){
		body.pos = cpv(240.0f + 30.0f, -30.0f);
		body.vel = cpv(-150.0f, 500.0f);
	}
}

@end
