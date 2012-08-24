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

#import "Exhibition.h"
#import "Globals.h"

@implementation Exhibition

float countDown = 50;

float anim = 0.0f;
float z = 0.0f;
float x = 1.0f;
float speed = 0.0f;

- (id) init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void) initialize {
    textures = [[Textures alloc] init];
    [textures load];
    
    floorPlan = [[FloorPlan alloc] init];
    
    float border = 0.05f;
    float size = 0.1f;
    
    nextButton = [[Quads alloc] init];
    [nextButton beginWithTexture:nextButtonTexture];
    [nextButton setOrthoProjection];
    [nextButton addQuadX1:1.0f - border y1:border z1:0.0f
                       x2:1.0f - border y2:border + size z2:0.0f
                       x3:1.0f - border - size y3:border + size z3:0.0f
                       x4:1.0f - border - size y4:border z4:0.0f];
    [nextButton end];

    prevButton = [[Quads alloc] init];
    [prevButton beginWithTexture:prevButtonTexture];
    [prevButton setOrthoProjection];
    [prevButton addQuadX1:border + size y1:border z1:0.0f
                       x2:border + size y2:border + size z2:0.0f
                       x3:border y3:border + size z3:0.0f
                       x4:border y4:border z4:0.0f];
    [prevButton end];
}

- (void) createExhibition {
    [floorPlan createFloorPlan];
}

- (void) tap:(GLKVector2)p {
    [floorPlan nextPhoto];
}

- (void) update {
    [floorPlan update];
}

- (void) render {
    [floorPlan render];
    if ([floorPlan isBackNextButtonsVisible]) {
	    [nextButton render];
	    [prevButton render];
    }
}

@end
