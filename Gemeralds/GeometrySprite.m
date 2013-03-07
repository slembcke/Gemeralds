/* Copyright (c) 2013 Scott Lembcke and Howling Moon Software
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


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
		
		// You could also use [simplified toConvexHulls_BETA:] if you don't want a single convex hull.
		
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
	
	// Overwrite the mass properties only if the body is dynamic.
	if(!body.isStatic){
		body.mass = mass;
		body.moment = moment;
	}
	
	NSArray *extras = [self setupExtras];
	_chipmunkObjects = [chipmunkObjects arrayByAddingObjectsFromArray:extras];
	[self.spaceNode.space add:self];
}

@end
