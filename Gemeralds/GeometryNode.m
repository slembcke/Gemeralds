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

-(void)onEnter
{
	[super onEnter];
	
	SpaceNode *spaceNode = [SpaceNode spaceNode:self];
	ChipmunkSpace *space = spaceNode.space;
	NSMutableArray *chipmunkObjects = [NSMutableArray array];
	
	// TODO: Should this make a non-shared body at the anchor point instead?
	// Possibly avoid alignment issues if you have nodes arranged with weird parent transforms
	ChipmunkBody *body = space.staticBody;
	
	NSString *group = [spaceNode identifierForKey:self.group];
	
	CGRect bounds = self.boundingBox;
	CGSize size = bounds.size;
	cpFloat downsample = self.downsample;
	ChipmunkGLRenderBufferSampler *sampler = [[ChipmunkGLRenderBufferSampler alloc] initWithXSamples:size.width/downsample ySamples:size.height/downsample];
	sampler.renderBounds = bounds;
	[sampler setBorderValue:0.0];
	
	// Render the scene into the renderbuffer so it's ready to be processed
	[sampler renderInto:^{[self visit];}];
	
	// Confusingly, the coordinates returned by the render buffer sampler are in renderbuffer pixel coordinates.
	// These coordinates won't quite line up with Cocos2D points or anything.
	// Setup an affine transform to convert them.
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform = CGAffineTransformTranslate(transform, bounds.origin.x, bounds.origin.y);
	transform = CGAffineTransformScale(transform, downsample, downsample);
	
	for(ChipmunkPolyline *polyline in [sampler marchAllWithBorder:TRUE hard:FALSE]){
		// Simplify the line data to ignore details smaller than the downsampling resolution.
		// Because of how the sampler was set up, the units will be in render buffer pixels, not Cocos2D points or pixels.
		ChipmunkPolyline *simplified = [polyline simplifyCurves:1.0f];
		for(ChipmunkPolyline *hull in [simplified toConvexHulls_BETA:1.0]){
			// Annoying step to convert the coordinates.
			cpVect verts[hull.count - 1];
			for(int i=0; i<hull.count - 1; i++){
				verts[i] = CGPointApplyAffineTransform(hull.verts[i], transform);
			}
			
			ChipmunkShape *poly = [ChipmunkPolyShape polyWithBody:body count:hull.count - 1 verts:verts offset:cpvzero];
			poly.friction = self.friction;
			poly.elasticity = self.elasticity;
			poly.group = group;
			[chipmunkObjects addObject:poly];
		}
	}
	
	_chipmunkObjects = chipmunkObjects;
	[space add:self];
}

@end
