//
//  GeometrySprite.h
//  Gemeralds
//
//  Created by Scott Lembcke on 12/19/12.
//  Copyright 2012 Howling Moon Software. All rights reserved.
//

#import "ObjectiveChipmunk.h"
#import "cocos2d.h"

@interface GeometrySprite : CCPhysicsSprite <ChipmunkObject> {
    
}

@property(nonatomic, assign) float downsample;
@property(nonatomic, assign) float density;
@property(nonatomic, assign) float friction;
@property(nonatomic, assign) float elasticity;

@property(nonatomic, readonly) NSArray *chipmunkObjects;

@end
