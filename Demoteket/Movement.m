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
    velocity = GLKVector2Make(0.0f, 0.0f);
    angle = 0.0f;
    angleTransition = 1.0f;
    paused = false;
}

- (void) setAngle:(float)a {
    angle = a;
}

- (void) setPosition:(GLKVector2)p {
    position = p;
}

- (void) setPositionToFirstPoint {
    position = points[0].position;
}

- (void) addPoint:(GLKVector2)p pause:(bool)pause {
    if (pointsCount > 0) {
	    points[pointsCount].type = points[pointsCount - 1].type;
	    points[pointsCount].lookAt = points[pointsCount - 1].lookAt;
    } else {
	    points[pointsCount].type = MOVEMENT_TYPE_ANGLE_IN_MOVING_DIR;
    }
    points[pointsCount].position = p;
    points[pointsCount].pause = pause;
    pointsCount++;
    if (pointsCount == 1) {
        oldDestAnglePoint = points[0];
    }
}

- (void) addPoint:(GLKVector2)p lookAt:(GLKVector2)lookAt pause:(bool)pause {
    points[pointsCount].type = MOVEMENT_TYPE_ANGLE_LOOK_AT;
    points[pointsCount].position = p;
    points[pointsCount].lookAt = [self getOffsetPoint:lookAt];
    points[pointsCount].pause = pause;
    pointsCount++;
}

- (void) addPoint:(GLKVector2)p lookIn:(float)a pause:(bool)pause {
    points[pointsCount].type = MOVEMENT_TYPE_ANGLE_LOOK_IN;
    points[pointsCount].position = p;
    points[pointsCount].lookIn = a;
    points[pointsCount].pause = pause;
    pointsCount++;
}

- (void) addPointInMovingDirection:(GLKVector2)p pause:(bool)pause {
    points[pointsCount].type = MOVEMENT_TYPE_ANGLE_IN_MOVING_DIR;
    points[pointsCount].position = p;
    points[pointsCount].pause = pause;
    pointsCount++;
}

- (void) addOffsetPoint:(GLKVector2)p pause:(bool)pause {
    [self addPoint:[self getOffsetPoint:p] pause:pause];
}

- (void) addOffsetPoint:(GLKVector2)p lookAt:(GLKVector2)lookAt pause:(bool)pause {
    [self addPoint:[self getOffsetPoint:p] lookAt:lookAt pause:pause];
}

- (void) addOffsetPointInMovingDirection:(GLKVector2)p pause:(bool)pause {
    [self addPointInMovingDirection:[self getOffsetPoint:p] pause:pause];
}

- (void) addOffsetPoint:(GLKVector2)p {
    [self addPoint:[self getOffsetPoint:p] pause:false];
}

- (void) addOffsetPoint:(GLKVector2)p lookAt:(GLKVector2)lookAt {
    [self addPoint:[self getOffsetPoint:p] lookAt:lookAt pause:false];
}

- (void) addOffsetPoint:(GLKVector2)p lookIn:(float)a {
    [self addPoint:[self getOffsetPoint:p] lookIn:a pause:false];
}

- (void) addOffsetPointInMovingDirection:(GLKVector2)p {
    [self addPointInMovingDirection:[self getOffsetPoint:p] pause:false];
}

- (GLKVector2) getOffsetPoint:(GLKVector2)p {
    return GLKVector2Add(p, pointsCount > 0 ? points[pointsCount - 1].position : GLKVector2Make(0.0f, 0.0f));
}

- (void) move:(float)t {
    [self updateMovement];
    [self updatePath];
    [self updateAngle];
}

- (void) resume {
    paused = false;
    [self nextPoint];
}

- (void) updateMovement {
    GLKVector2 targetOffset = GLKVector2Subtract(points[pointIndex].position, position);
    float distance = GLKVector2Length(targetOffset);
    if (distance <= 0.0f) {
        return;
    }
    float slowingDistance = points[pointIndex].pause ? MOVEMENT_SLOWING_DISTANCE : distance;
    float rampedSpeed = MOVEMENT_MAX_SPEED * distance / slowingDistance;
    float clippedSpeed = MIN(rampedSpeed, MOVEMENT_MAX_SPEED);
    GLKVector2 desiredVelocity = GLKVector2MultiplyScalar(targetOffset, clippedSpeed / distance);
    GLKVector2 steering = GLKVector2Subtract(desiredVelocity, velocity);
    if (GLKVector2Length(steering) > MOVEMENT_STEERING_SPEED) {
        steering = GLKVector2MultiplyScalar(GLKVector2Normalize(steering), MOVEMENT_STEERING_SPEED);
    }
    velocity = GLKVector2Add(velocity, steering);
    position = GLKVector2Add(position, velocity);
}

- (void) updateAngle {
    float destAngle = [self calculateAngle:points[pointIndex]];
	if (ABS(angle - destAngle) > M_PI) {
        angle += M_PI * 2.0f * (angle < destAngle ? 1.0f : -1.0f);
    }
    float oldDestAngle = [self calculateAngle:oldDestAnglePoint];
	if (ABS(oldDestAngle - destAngle) > M_PI) {
        oldDestAngle += M_PI * 2.0f * (oldDestAngle < destAngle ? 1.0f : -1.0f);
    }
	angle = destAngle + ((cos(angleTransition * M_PI) + 1.0f) * 0.5f * (oldDestAngle - destAngle));
    angleTransition = MIN(angleTransition + ANGLE_TRANSITION_SPEED, 1.0f);
}

- (float) calculateAngle:(MovementPoint)point {
    if (point.type != MOVEMENT_TYPE_ANGLE_LOOK_IN) {
	    GLKVector2 dir = point.type == MOVEMENT_TYPE_ANGLE_LOOK_AT ? GLKVector2Subtract(point.lookAt, position) : velocity;
	    if (GLKVector2Length(dir) <= 0.0f) {
	        return 0.0f;
	    }
	    GLKVector2 lookAt = GLKVector2Normalize(dir);
	    return atan2f(lookAt.y, lookAt.x) + M_PI * 2.0f - M_PI_2;
    } else {
        return point.lookIn;
    }
}

- (void) updatePath {
    if (paused || GLKVector2Distance(position, points[pointIndex].position) > MOVEMENT_POINT_DISTANCE) {
        return;
    }
    if (points[pointIndex].pause) {
        paused = true;
        return;
    }
    [self nextPoint];
}

- (void) nextPoint {
    MovementPoint oldPoint = points[pointIndex];
    pointIndex = MIN(pointIndex + 1, pointsCount - 1);
    MovementPoint newPoint = points[pointIndex];
    if (oldPoint.type != newPoint.type) {
        //angleTransition = 0.0f;
    } else if (newPoint.type == MOVEMENT_TYPE_ANGLE_LOOK_AT && !GLKVector2AllEqualToVector2(newPoint.lookAt, oldPoint.lookAt)) {
        oldDestAnglePoint = oldPoint;
        angleTransition = 0.0f;
    }
}

- (GLKVector3) getPositionAndAngle {
    return GLKVector3Make(position.x, position.y, angle);
}

@end