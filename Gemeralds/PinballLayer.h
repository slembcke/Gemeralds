//
//  PinballLayer.h
//  Gemeralds
//
//  Created by Scott Lembcke on 2/28/13.
//  Copyright 2013 Howling Moon Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class FlipperSprite;

@interface PinballLayer : CCLayer

@property(nonatomic, strong) CCNode *followNode;

-(void)addFlipper:(FlipperSprite *)flipper;

@end
