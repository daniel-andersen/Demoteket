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

#import "Movement.h"

@implementation Movement

- (id) init {
    if (self = [super init]) {
        [self reset];
    }
    return self;
}

- (void) reset {
    pointsCount = 0;
    pointIndex = 0;
    movement = GLKVector2Make(0.0f, 0.0f);
    velocity = GLKVector2Make(0.0f, 0.0f);
    angle = 0.0f;
    destAngle = angle;
    angleVelocity = 0.0f;
}

- (void) setAngle:(float)a {
    angle = a;
}

- (void) setPosition:(GLKVector2)p {
    position = p;
}

- (void) setPositionToFirstPoint {
    position = points[0];
}

- (void) addPoint:(GLKVector2)p {
    points[pointsCount] = p;
    angles[pointsCount] = -1.0f;
    pointsCount++;
}

- (void) addPoint:(GLKVector2)p angle:(float)a {
    points[pointsCount] = p;
    angles[pointsCount] = a;
    pointsCount++;
}

- (void) move:(float)t {
    [self updateMovement];
    [self updatePath];
    [self updateAngle];
}

- (void) updateMovement {
    GLKVector2 desiredVelocity = GLKVector2Subtract(points[pointIndex], position);
    float l = GLKVector2Length(desiredVelocity);
    if (l <= 0.0f) {
        return;
    }
    l = MAX(MIN(l, MOVEMENT_VELOCITY_SPEED), MOVEMENT_VELOCITY_SPEED_MIN);
	velocity = GLKVector2MultiplyScalar(GLKVector2Normalize(desiredVelocity), l);
    movement = GLKVector2Add(movement, velocity);
    if (GLKVector2Length(movement) > MOVEMENT_MAX_SPEED) {
        movement = GLKVector2MultiplyScalar(GLKVector2Normalize(movement), MOVEMENT_MAX_SPEED);
    }
    position = GLKVector2Add(position, movement);
}

- (void) updateAngle {
    [self calculateDestAngle];
	if (ABS(angle - destAngle) > M_PI) {
        angle += M_PI * 2.0f * (angle < destAngle ? 1.0f : -1.0f);
    }
    float desiredVelocity = MAX(MIN((destAngle - angle) * 0.1f, ANGLE_MAX_SPEED), -ANGLE_MAX_SPEED);
    if (angleVelocity < desiredVelocity) {
        angleVelocity = MIN(angleVelocity + ANGLE_VELOCITY, desiredVelocity);
    } else {
        angleVelocity = MAX(angleVelocity - ANGLE_VELOCITY, desiredVelocity);
    }
    angle += angleVelocity;
}

- (void) updatePath {
    if (GLKVector2Distance(position, points[pointIndex]) > MOVEMENT_POINT_DISTANCE) {
        return;
    }
    pointIndex = MIN(pointIndex + 1, pointsCount - 1);
}

- (void) calculateDestAngle {
    if (pointIndex > 0 && angles[pointIndex - 1] != -1.0f) {
        destAngle = angles[pointIndex - 1];
    } else {
	    if (GLKVector2Length(movement) <= 0.0f) {
    	    return;
	    }
	    GLKVector2 dir = GLKVector2Normalize(movement);
	    destAngle = atan2f(dir.y, dir.x) + M_PI * 2.0f - M_PI_2;
    }
}

- (GLKVector3) getPositionAndAngle {
    return GLKVector3Make(position.x, position.y, angle);
}

@end
