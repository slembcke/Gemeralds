//
//  ChipmunkGeometryNode.m
//  Gemeralds
//
//  Created by Scott Lembcke on 12/17/12.
//  Copyright 2012 Howling Moon Software. All rights reserved.
//

#import "ObjectiveChipmunk.h"
#import "GeometryNode.h"
#import "SpaceNode.h"

#import "ChipmunkGLRenderBufferSampler.h"

@implementation GeometryNode {
}

-(id)init
{
	if((self = [super init])){
		_downsample = 2.0;
	}
	
	return self;
}

// Look up the parent node chain for the SpaceNode.
-(SpaceNode *)spaceNode
{
	for(CCNode *node = self.parent;; node = node.parent){
		if([node isKindOfClass:[SpaceNode class]]){
			return (id)node;
		}
	}
	
	@throw [NSException exceptionWithName:@"GeometryNodeError" reason:@"Geometry node does not have a parent of type SpacenNode" userInfo:nil];
}

-(void)onEnter
{
	ChipmunkSpace *space = self.spaceNode.space;
	NSMutableArray *chipmunkObjects = [NSMutableArray array];
	
	// TODO: Should this make a non-shared body at the anchor point instead?
	// Possibly avoid alignment issues if you have nodes arranged with weird parent transforms
	ChipmunkBody *body = space.staticBody;
	
	NSString *group = [self.spaceNode identifierForKey:self.group];
	
	CGRect bounds = self.boundingBox;
	CGSize size = bounds.size;
	cpFloat downsample = self.downsample;
	ChipmunkGLRenderBufferSampler *sampler = [[ChipmunkGLRenderBufferSampler alloc] initWithXSamples:size.width/downsample ySamples:size.height/downsample];
	sampler.renderBounds = bounds;
//	sampler.outputRect = cpBBNew(CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
//	sampler.borderValue = 1.0;
	
	// Render the scene into the renderbuffer so it's ready to be processed
	[sampler renderInto:^{[self visit];}];
	
	// Confusingly, the coordinates returned by the render buffer sampler are in pixel coordinates.
	// These coordinates won't quite line up with Cocos2D points or anything.
	// Setup an affine transform to convert them.
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform = CGAffineTransformTranslate(transform, bounds.origin.x, bounds.origin.y);
	transform = CGAffineTransformScale(transform, downsample, downsample);
	
	for(ChipmunkPolyline *polyline in [sampler marchAllWithBorder:FALSE hard:FALSE]){
		// Simplify the line data to ignore details smaller than the downsampling resolution.
		// Because of how the sampler was set up, the units will be in render buffer pixels, not Cocos2D points or pixels.
		ChipmunkPolyline *simplified = [polyline simplifyCurves:1.0f];
		
		for(int i=0; i<simplified.count-1; i++){
			cpVect a = CGPointApplyAffineTransform(simplified.verts[  i], transform);
			cpVect b = CGPointApplyAffineTransform(simplified.verts[i+1], transform);
			
			ChipmunkShape *seg = [ChipmunkSegmentShape segmentWithBody:body from:a to:b radius:1.0f];
			seg.friction = self.friction;
			seg.elasticity = self.elasticity;
			seg.group = group;
			[chipmunkObjects addObject:seg];
		}
	}
	
	_chipmunkObjects = chipmunkObjects;
	[space add:self];
}

@end
