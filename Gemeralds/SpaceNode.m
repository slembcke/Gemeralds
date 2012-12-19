//
//  SpaceNode.m
//  Gemeralds
//
//  Created by Scott Lembcke on 12/19/12.
//  Copyright 2012 Howling Moon Software. All rights reserved.
//

#import "SpaceNode.h"


@implementation SpaceNode {
	CCPhysicsDebugNode *_debugNode;
}

-(id)init
{
	if((self = [super init])){
		_space = [[ChipmunkSpace alloc] init];
		_space.gravity = cpv(0, -300);
		
		_debugNode = [CCPhysicsDebugNode debugNodeForChipmunkSpace:_space];
//		_debugNode.visible = FALSE;
		[self addChild:_debugNode z:1000];
	}
	
	return self;
}

@end
