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
	self.pinballLayer.followNode = self;
	
	[super onEnter];
}

@end
