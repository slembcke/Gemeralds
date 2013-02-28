//
//  SpaceNode.h
//  Gemeralds
//
//  Created by Scott Lembcke on 12/19/12.
//  Copyright 2012 Howling Moon Software. All rights reserved.
//

#import "ObjectiveChipmunk.h"
#import "cocos2d.h"

@interface SpaceNode : CCNode

@property(nonatomic, readonly) ChipmunkSpace *space;
@property(nonatomic, readonly) CCPhysicsDebugNode *debugNode;

-(NSString *)identifierForKey:(NSString *)key;

@end
