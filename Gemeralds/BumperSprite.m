//
//  BumberSprite.m
//  Gemeralds
//
//  Created by Scott Lembcke on 2/28/13.
//  Copyright 2013 Howling Moon Software. All rights reserved.
//

#import "BumperSprite.h"


@implementation BumperSprite

-(id)init
{
	if((self = [super init])){
		self.friction = 0.8;
		self.elasticity = 0.0;
	}
	
	return self;
}

-(BOOL)isStatic
{
	return TRUE;
}

-(NSString *)group
{
	return @"table";
}

@end
