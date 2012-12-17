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

-(void)onEnter
{
	_space = [[ChipmunkSpace alloc] init];
	_space.gravity = cpv(0, -300);
	
	CCPhysicsDebugNode *debugNode = [CCPhysicsDebugNode debugNodeForChipmunkSpace:_space];
	[self addChild:debugNode z:1000];
	
	ChipmunkGLRenderBufferSampler *sampler = [[ChipmunkGLRenderBufferSampler alloc] initWithWidth:480 height:320];
	sampler.borderValue = 1.0;
	
	// Render the scene into the renderbuffer so it's ready to be processed
	[sampler renderInto:^{[self visit];}];
	
	for(ChipmunkPolyline *polyline in [sampler marchAllWithBorder:TRUE hard:FALSE]){
		// Simplify the line data to ignore details smaller than a pixel.
		ChipmunkPolyline *simplified = [polyline simplifyCurves:1.0f];
		
		for(int i=0; i<simplified.count-1; i++){
			cpVect a = simplified.verts[i];
			cpVect b = simplified.verts[i+1];
			
			ChipmunkShape *seg = [ChipmunkSegmentShape segmentWithBody:_space.staticBody from:a to:b radius:1.0f];
			seg.friction = 1.0;
			[_space add:seg];
		}
	}
}

@end
