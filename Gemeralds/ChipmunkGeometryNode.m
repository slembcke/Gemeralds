//
//  ChipmunkGeometryNode.m
//  Gemeralds
//
//  Created by Scott Lembcke on 12/17/12.
//  Copyright 2012 Howling Moon Software. All rights reserved.
//

#import "ObjectiveChipmunk.h"
#import "ChipmunkGeometryNode.h"

#import "ChipmunkGLRenderBufferSampler.h"

@implementation ChipmunkGeometryNode {
	ChipmunkSpace *_space;
}

-(id)init
{
	if((self = [super init])){
		_space = [[ChipmunkSpace alloc] init];
		_space.gravity = cpv(0, -300);
		
		CCPhysicsDebugNode *debugNode = [CCPhysicsDebugNode debugNodeForChipmunkSpace:_space];
		[self addChild:debugNode z:1000];
		
		ChipmunkGLRenderBufferSampler *sampler = [[ChipmunkGLRenderBufferSampler alloc] initWithWidth:350/2 height:250/2];
		sampler.borderValue = 1.0;
		
		// Render the scene into the renderbuffer so it's ready to be processed
		[sampler renderInto:^{[self visit];}];
		
		for(ChipmunkPolyline *polyline in [sampler marchAllWithBorder:TRUE hard:FALSE]){
			// Simplify the line data to ignore details smaller than a pixel.
			ChipmunkPolyline *simplified = [polyline simplifyCurves:1.0f];
			
			// Ignore a loop if it has a small amount of area.
			// This avoids tiny little floating chunks of dirt.
//			if(simplified.isLooped && simplified.area < 100) continue;
			
			for(int i=0; i<simplified.count-1; i++){
				cpVect a = simplified.verts[i];
				cpVect b = simplified.verts[i+1];
				
				ChipmunkShape *seg = [ChipmunkSegmentShape segmentWithBody:_space.staticBody from:a to:b radius:1.0f];
				seg.friction = 1.0;
				[_space add:seg];
			}
		}
	}
	
	return self;
}

@end
