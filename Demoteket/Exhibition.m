// Copyright (c) 2012, Daniel Andersen (dani_ande@yahoo.dk)
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products derived
//    from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <math.h>

#import "Exhibition.h"
#import "Globals.h"

@implementation Exhibition

int countDown = 50;

float anim = 0.0f;
float z = 0.0f;

- (id) init {
    if (self = [super init]) {
        textures = [[Textures alloc] init];
        [textures load];

        floorPlan = [[FloorPlan alloc] init];
    }
    return self;
}

- (void) createExhibition {
    [floorPlan createFloorPlan];
}

- (void) render {
    countDown--;
    if (countDown < 0 && countDown > -300) {
	    z += 0.04f;
	    anim += 0.025f;
    }
    float x = -sin(anim - 1.0f) * 2.5f;
    float a = sin(anim) * 0.6f;
    sceneModelViewMatrix = GLKMatrix4Identity;
    sceneModelViewMatrix = GLKMatrix4Rotate(sceneModelViewMatrix, a, 0.0f, 1.0f, 0.0f);
    sceneModelViewMatrix = GLKMatrix4Translate(sceneModelViewMatrix, -5.0f + x, -2.0f, -18.0f + z);

    [floorPlan render];
}

@end
