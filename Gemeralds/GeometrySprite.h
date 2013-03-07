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


// GeometrySprite is the class used in a CocosBuilder scene that generates convex hulls
// for it's child sprite. It must be added as a child of a SpaceNode.
// It can be either dynamic or static. The anchor point will be used as the center of gravity.

#import "ObjectiveChipmunk.h"
#import "cocos2d.h"

@interface GeometrySprite : CCPhysicsSprite <ChipmunkObject>

// This is the factor to reduce the resolution by when generating geometry.
// Normally the geometry is rendered in points (not pixels).
// A higher downsampling value makes the processing run faster, but produces lower quality output.
@property(nonatomic, assign) float downsample;

@property(nonatomic, assign) float density;
@property(nonatomic, assign) float friction;
@property(nonatomic, assign) float elasticity;
@property(nonatomic, copy) NSString *group;
@property(nonatomic, copy) NSString *collisionType;

@property(nonatomic, readonly) BOOL isStatic;

@property(nonatomic, readonly) NSArray *chipmunkObjects;

// This is used for setting up joints on the FlipperSprite subclass.
-(NSArray *)setupExtras;

@end
