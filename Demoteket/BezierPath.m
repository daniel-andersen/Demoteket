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

#import "BezierPath.h"

@implementation BezierPath

- (id) init {
    if (self = [super init]) {
        pointsCount = 0;
        nextIndex = 3;
        currentAngle = 0.0f;
        destAngle = 0.0f;
        t = 0.0f;
    }
    return self;
}

- (void) setAngle:(float)angle {
    currentAngle = angle;
}

- (void) addPoint:(GLKVector2)p {
    points[pointsCount] = p;
    if (pointsCount == 0) {
        currentPosition = p;
    }
    if (pointsCount < 3) {
        currentPoints[pointsCount] = p;
    }
    pointsCount++;
}

- (void) move:(float)speed {
    t += [self normalizeLength:speed];
    [self updatePath];
    [self calculatePosition];
    [self updateAngle];
}

- (void) updateAngle {
    currentAngle = destAngle;
}

- (void) updatePath {
    if (t < BEZIER_DEST) {
        return;
    }
    [self projectPseudoBezierPoint];

    currentPoints[0] = currentPosition;
    currentPoints[2] = points[nextIndex];

    t -= BEZIER_DEST;//[self normalizeLength:BEZIER_DEST - t];
    
	nextIndex++;
    if (nextIndex >= pointsCount) {
        nextIndex = 0;
    }
}

- (float) normalizeLength:(float)l {
    float currentLength = GLKVector2Length(GLKVector2Subtract(currentPoints[0], currentPoints[1])) +
    					  GLKVector2Length(GLKVector2Subtract(currentPoints[1], currentPoints[2]));
    return l * BEZIER_NORMAL_LENGTH / currentLength;;
}

- (void) projectPseudoBezierPoint {
    float l = GLKVector2Distance(currentPosition, currentPoints[2]);
    GLKVector2 dir = GLKVector2Normalize(GLKVector2Subtract(currentPosition, lastPosition));
    currentPoints[1] = GLKVector2Add(currentPosition, GLKVector2MultiplyScalar(dir, l));
}

- (void) calculatePosition {
    lastPosition = currentPosition;

    GLKVector2 p0 = GLKVector2Make(currentPoints[0].x, currentPoints[0].y);
    GLKVector2 p1 = GLKVector2Make(currentPoints[1].x, currentPoints[1].y);
    GLKVector2 p2 = GLKVector2Make(currentPoints[2].x, currentPoints[2].y);
    
    GLKVector2 v1 = GLKVector2MultiplyScalar(p0, pow(1.0f - t, 2.0f));
    GLKVector2 v2 = GLKVector2MultiplyScalar(p1, 2.0f * (1.0f - t) * t);
    GLKVector2 v3 = GLKVector2MultiplyScalar(p2, pow(t, 2.0f));
    
    currentPosition = GLKVector2Add(GLKVector2Add(v1, v2), v3);

    GLKVector2 dir = GLKVector2Normalize(GLKVector2Subtract(currentPosition, lastPosition));
    destAngle = atan2f(dir.y, dir.x) + M_PI * 2.0f - M_PI_2;
}

- (GLKVector3) getPositionAndAngle {
    return GLKVector3Make(currentPosition.x, currentPosition.y, currentAngle);
}

@end
