//
//  ChipmunkGeometryNode.h
//  Gemeralds
//
//  Created by Scott Lembcke on 12/17/12.
//  Copyright 2012 Howling Moon Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GeometryNode : CCNode <ChipmunkObject>

@property(nonatomic, assign) float downsample;
@property(nonatomic, assign) float friction;
@property(nonatomic, assign) float elasticity;

@property(nonatomic, copy) NSString *group;

@property(nonatomic, readonly) NSArray *chipmunkObjects;

@end
