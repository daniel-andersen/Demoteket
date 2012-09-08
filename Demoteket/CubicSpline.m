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

#import "CubicSpline.h"

@implementation CubicSpline

- (id) init {
    if (self = [super init]) {
        splinePointCount = 0;
    }
    return self;
}

- (void) setFirstPoint:(GLKVector2)p {
    splinesX[0].x = p.x;
    splinesY[0].x = p.y;
    if (splinePointCount == 0) {
        splinePointCount = 1;
    }
    recalculate = true;
}

- (void) addPoint:(GLKVector2)p {
    splinesX[splinePointCount].x = p.x;
    splinesY[splinePointCount].x = p.y;
    splinePointCount++;
    recalculate = true;
}

- (void) addOffsetPoint:(GLKVector2)p {
    if (splinePointCount == 0) {
	    splinesX[splinePointCount].x = p.x;
	    splinesY[splinePointCount].x = p.y;
    } else {
	    splinesX[splinePointCount].x = splinesX[splinePointCount - 1].x + p.x;
	    splinesY[splinePointCount].x = splinesY[splinePointCount - 1].x + p.y;
    }
    splinePointCount++;
    recalculate = true;
}

- (GLKVector2) getPosition:(float)t {
    if (splinePointCount == 0) {
        return GLKVector2Make(0.0f, 0.0f);
    }
    if (recalculate) {
        [self recalculateSpline];
        recalculate = false;
    }
    int index = (int) t;
    if (index >= splinePointCount) {
        index = splinePointCount - 1;
        t = 1.0f;
    } else {
	    t -= (float) index;
    }
    return GLKVector2Make(
                          (((splinesX[index].d * t) + splinesX[index].c) * t + splinesX[index].b) * t + splinesX[index].a,
                          (((splinesY[index].d * t) + splinesY[index].c) * t + splinesY[index].b) * t + splinesY[index].a);
}

- (void) recalculateSpline {
    [self calculateSpline:splinesX];
    [self calculateSpline:splinesY];
}

- (GLKVector2) getEndPosition {
    return [self getPosition:[self getEndOffset]];
}

- (float) getEndOffset {
    return (float) splinePointCount - 1.0f;
}

- (void) calculateSpline:(SplinePoint*)p {
    p[splinePointCount].x = p[splinePointCount - 1].x;

    float gamma[splinePointCount + 1];
    float delta[splinePointCount + 1];
    float D[splinePointCount + 1];
    
    gamma[0] = 1.0f / 2.0f;
    for (int i = 1; i < splinePointCount; i++) {
        gamma[i] = 1.0f / (4.0f - gamma[i - 1]);
    }
    gamma[splinePointCount] = 1.0f / (2.0f - gamma[splinePointCount - 1]);
    
    delta[0] = 3.0f * (p[1].x - p[0].x) * gamma[0];
    for (int i = 1; i < splinePointCount; i++) {
        delta[i] = (3.0f * (p[i + 1].x - p[i - 1].x) - delta[i - 1]) * gamma[i];
    }
    delta[splinePointCount] = (3.0f * (p[splinePointCount].x - p[splinePointCount - 1].x) - delta[splinePointCount - 1]) * gamma[splinePointCount];
    
    D[splinePointCount] = delta[splinePointCount];
    for (int i = splinePointCount - 1; i >= 0; i--) {
        D[i] = delta[i] - gamma[i] * D[i + 1];
    }
    
    for (int i = 0; i < splinePointCount; i++) {
	    p[i].a = p[i].x;
        p[i].b = D[i];
        p[i].c = 3.0f * (p[i + 1].x - p[i].x) - 2.0f * D[i] - D[i + 1];
        p[i].d = 2.0f * (p[i].x - p[i + 1].x) + D[i] + D[i + 1];
    }
}

@end
