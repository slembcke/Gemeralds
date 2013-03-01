//
//  GeometrySprite.h
//  Gemeralds
//
//  Created by Scott Lembcke on 12/19/12.
//  Copyright 2012 Howling Moon Software. All rights reserved.
//

#import "ObjectiveChipmunk.h"
#import "cocos2d.h"

@interface GeometrySprite : CCPhysicsSprite <ChipmunkObject>

@property(nonatomic, assign) float downsample;
@property(nonatomic, assign) float density;
@property(nonatomic, assign) float friction;
@property(nonatomic, assign) float elasticity;
@property(nonatomic, copy) NSString *group;
@property(nonatomic, copy) NSString *collisionType;

@property(nonatomic, readonly) BOOL isStatic;

@property(nonatomic, readonly) NSArray *chipmunkObjects;

// This is used for setting up joints on the FlipperSprite subclass.
-(NSArray *)setupExtras;

@end
