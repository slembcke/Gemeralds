//
//  GeometrySprite.m
//  Gemeralds
//
//  Created by Scott Lembcke on 12/19/12.
//  Copyright 2012 Howling Moon Software. All rights reserved.
//

#import "ObjectiveChipmunk.h"
#import "GeometrySprite.h"
#import "SpaceNode.h"
#import "ChipmunkGLRenderBufferSampler.h"


@implementation GeometrySprite {
}

-(id)init
{
	if((self = [super init])){
		_downsample = 2.0;
		_density = 1.0;
		
		if(self.isStatic){
			self.chipmunkBody = [ChipmunkBody staticBody];
		} else {
			// Start with a body with infinite mass and fill it in later.
			self.chipmunkBody = [ChipmunkBody bodyWithMass:INFINITY andMoment:INFINITY];
		}
	}
	
	return self;
}

-(BOOL)isStatic
{
	return FALSE;
}

// Look up the parent node chain for the SpaceNode.
-(SpaceNode *)spaceNode
{
	for(CCNode *node = self.parent;; node = node.parent){
		if([node isKindOfClass:[SpaceNode class]]){
			return (id)node;
		}
	}
	
	@throw [NSException exceptionWithName:@"GeometryNodeError" reason:@"GeometrySprite does not have a parent of type SpacenNode" userInfo:nil];
}

-(NSArray *)setupExtras;
{
	return nil;
}

-(void)onEnter
{
	[super onEnter];
	
	NSMutableArray *chipmunkObjects = [NSMutableArray array];
	ChipmunkBody *body = self.chipmunkBody;
	if(!body.isStatic) [chipmunkObjects addObject:body];
	
	CGRect bounds = self.boundingBox;
	CGSize size = bounds.size;
	cpFloat downsample = self.downsample;
	ChipmunkGLRenderBufferSampler *sampler = [[ChipmunkGLRenderBufferSampler alloc] initWithXSamples:size.width/downsample ySamples:size.height/downsample];
	sampler.renderBounds = bounds;
//	sampler.outputRect = cpBBNew(CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
	sampler.borderValue = 0.0;
	
	// Render the scene into the renderbuffer so it's ready to be processed
	[sampler renderInto:^{[self visit];}];
	
	// Confusingly, the coordinates returned by the render buffer sampler are in pixel coordinates.
	// These coordinates won't quite line up with Cocos2D points or anything.
	// Setup an affine transform to convert them.
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform = CGAffineTransformRotate(transform, -self.chipmunkBody.angle);
	transform = CGAffineTransformTranslate(transform, bounds.origin.x - self.position.x, bounds.origin.y - self.position.y);
	transform = CGAffineTransformScale(transform, downsample, downsample);
	
	cpFloat mass = 0.0;
	cpFloat moment = 0.0;
	
	for(ChipmunkPolyline *polyline in [sampler marchAllWithBorder:TRUE hard:FALSE]){
		cpFloat area = polyline.area;
		if(area <= 0.0) continue; // Ignore holes
		
		// Simplify the line data to ignore details smaller than the downsampling resolution.
		// Because of how the sampler was set up, the units will be in render buffer pixels, not Cocos2D points or pixels.
		ChipmunkPolyline *simplified = [polyline simplifyCurves:1.0f];
		ChipmunkPolyline *hull = [simplified toConvexHull];
		
		int count = hull.count - 1;
		cpVect transformed[hull.count];
		for(int i=0; i<count; i++){
			transformed[i] = CGPointApplyAffineTransform(hull.verts[i], transform);
		}
		
		cpFloat m = area*self.density;
		mass += m;
		moment += cpMomentForPoly(m, count, transformed, cpvzero);
		
		ChipmunkShape *shape = [ChipmunkPolyShape polyWithBody:body count:count verts:transformed offset:cpvzero];
		shape.friction = self.friction;
		shape.elasticity = self.elasticity;
		shape.group = [self.spaceNode identifierForKey:self.group];
		shape.collisionType = [self.spaceNode identifierForKey:self.collisionType];
		[chipmunkObjects addObject:shape];
	}
	
	if(!body.isStatic){
		body.mass = mass;
		body.moment = moment;
	}
	
	NSArray *extras = [self setupExtras];
	_chipmunkObjects = [chipmunkObjects arrayByAddingObjectsFromArray:extras];
	[self.spaceNode.space add:self];
}

@end
