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


// GeometryNode is the class used in a CocosBuilder scene that generates static, outlined
// Chipmunk geometry for it's child sprites. It must be added as a child of a SpaceNode.
// The content size of the node is what provides the size of the area to be processed for geometry.

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GeometryNode : CCNode <ChipmunkObject>

// This is the factor to reduce the resolution by when generating geometry.
// Normally the geometry is rendered in points (not pixels).
// A higher downsampling value makes the processing run faster, but produces lower quality output.
@property(nonatomic, assign) float downsample;

@property(nonatomic, assign) float friction;
@property(nonatomic, assign) float elasticity;

@property(nonatomic, copy) NSString *group;

@property(nonatomic, readonly) NSArray *chipmunkObjects;

@end
