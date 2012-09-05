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
    movementType = MOVEMENT_DIR_FORWARD;
    velocity = GLKVector2Make(0.0f, 0.0f);
    paused = false;

    angle = 0.0f;
    angleTransition = 0.0f;
    oldDestAnglePoint.type = ANGLE_TYPE_LOOK_IN;
    oldDestAnglePoint.lookIn = angle;

    userPhotosCount = 0;
    
    userPhotoIndex = 0;
    anglePointIndex = 0;
    roomVisibilityIndex = 0;
    
    tourSplines = [[CubicSpline alloc] init];
    for (int i = 0; i < USER_PHOTOS_MAX_COUNT; i++) {
        walkSplines[i] = [[CubicSpline alloc] init];
        for (int j = 0; j < 4; j++) {
            anglePointCount[j][i] = 0;
            roomVisibilityCount[j][i] = 0;
        }
    }
}

- (void) setAngle:(float)a {
    angle = a;
}

- (void) setPosition:(GLKVector2)p {
    position = p;
}

- (void) setPositionToFirstPoint {
    [self setMovement:MOVEMENT_DIR_FORWARD];
    splineOffset = 0.0f;
    userPhotoIndex = 9;
    anglePointIndex = 0;
    roomVisibilityIndex = 0;
    position = [self getTargetPosition];
}

- (void) addUserPhoto:(PhotoInfo*)photoInfo {
    userPhotos[userPhotosCount++] = photoInfo;
}

- (void) setUserPhoto:(int)index {
    userPhotoIndex = index;
    anglePointIndex = 0;
}

- (void) setWalkPointToLastPoint {
    [walkSplines[userPhotoIndex] addPoint:[walkSplines[userPhotoIndex - 1] getEndPosition]];
}

- (void) addWalkPointAbsolute:(GLKVector2)p {
    [walkSplines[userPhotoIndex] addPoint:p];
}

- (void) addWalkPointRelative:(GLKVector2)p {
    [walkSplines[userPhotoIndex] addOffsetPoint:p];
}

- (void) addTourPointAbsolute:(GLKVector2)p {
    [tourSplines addPoint:p];
}

- (void) addTourPointRelative:(GLKVector2)p {
    [tourSplines addOffsetPoint:p];
}

- (void) lookAtRelativeToStart:(GLKVector2)p beginningAt:(float)t withDelay:(float)delay {
    AnglePoint *anglePoint = &anglePoints[movementType][userPhotoIndex][anglePointCount[movementType][userPhotoIndex]];
    anglePoint->type = ANGLE_TYPE_LOOK_AT;
    anglePoint->splineOffset = t;
    anglePoint->lookAt = GLKVector2Add(p, [self getStartPosition]);
    anglePoint->angleSpeed = 1.0f;
    anglePoint->continueDelay = delay;
    anglePointCount[movementType][userPhotoIndex]++;
}

- (void) lookAtRelativeToEnd:(GLKVector2)p beginningAt:(float)t withDelay:(float)delay {
    AnglePoint *anglePoint = &anglePoints[movementType][userPhotoIndex][anglePointCount[movementType][userPhotoIndex]];
    anglePoint->type = ANGLE_TYPE_LOOK_AT;
    anglePoint->splineOffset = t;
    anglePoint->lookAt = GLKVector2Add(p, [self getEndPosition]);
    anglePoint->angleSpeed = 1.0f;
    anglePoint->continueDelay = delay;
    anglePointCount[movementType][userPhotoIndex]++;
}

- (void) lookIn:(float)a beginningAt:(float)t withDelay:(float)delay {
    AnglePoint *anglePoint = &anglePoints[movementType][userPhotoIndex][anglePointCount[movementType][userPhotoIndex]];
    anglePoint->type = ANGLE_TYPE_LOOK_IN;
    anglePoint->splineOffset = t;
    anglePoint->lookIn = a;
    anglePoint->angleSpeed = 1.0f;
    anglePoint->continueDelay = delay;
    anglePointCount[movementType][userPhotoIndex]++;
}

- (void) showRoom:(int)index beginningAt:(float)t {
    RoomVisibility *visibility = &roomVisibility[movementType][userPhotoIndex][roomVisibilityCount[movementType][userPhotoIndex]];
    visibility->type = ROOM_VISIBILITY_TYPE_SHOW;
    visibility->splineOffset = t;
    visibility->roomIndex = index;
    roomVisibilityCount[movementType][userPhotoIndex]++;
}

- (void) hideRoom:(int)index beginningAt:(float)t {
    RoomVisibility *visibility = &roomVisibility[movementType][userPhotoIndex][roomVisibilityCount[movementType][userPhotoIndex]];
    visibility->type = ROOM_VISIBILITY_TYPE_HIDE;
    visibility->splineOffset = t;
    visibility->roomIndex = index;
    roomVisibilityCount[movementType][userPhotoIndex]++;
}

- (void) move:(float)t {
    [self updateAngle];
    if (angleTransition >= anglePoints[movementType][userPhotoIndex][anglePointIndex].continueDelay) {
        [self updatePath];
        [self updateMovement];
    } else {
        [self decreaseMovement];
    }
    [self updateRoomVisibility];
}

- (void) setMovement:(int)type {
    movementType = type;
}

- (void) resume {
    paused = false;
    splineOffset = 0.0f;
    userPhotoIndex++;
    oldDestAnglePoint.type = ANGLE_TYPE_LOOK_IN;
    oldDestAnglePoint.lookIn = angle;
    anglePointIndex = 0;
    angleTransition = 0.0f;
    roomVisibilityIndex = 0;
}

- (void) startTour {
    paused = false;
}

- (void) stopTour {
    movementType = movementType == MOVEMENT_DIR_FORWARD_TOUR ? MOVEMENT_DIR_FORWARD : MOVEMENT_DIR_BACKWARD;
}

- (PhotoInfo*) getCurrentPhoto {
    if (!paused) {
        return NULL;
    }
    return userPhotos[userPhotoIndex];
}

- (void) updateRoomVisibility {
    if (roomVisibilityIndex >= roomVisibilityCount[movementType][userPhotoIndex]) {
        return;
    }
    RoomVisibility *visibility = &roomVisibility[movementType][userPhotoIndex][roomVisibilityIndex];
    if (splineOffset > visibility->splineOffset) {
        if (roomVisibilityCallbackHandler != nil) {
	        roomVisibilityCallbackHandler(visibility->type, visibility->roomIndex);
        }
        roomVisibilityIndex++;
    }
}

- (void) updateMovement {
    GLKVector2 targetOffset = GLKVector2Subtract([self getTargetPosition], position);
    if (GLKVector2Length(targetOffset) <= 0.0f) {
        return;
    }
    float distanceToPause = GLKVector2Distance(position, [self getEndPosition]);
    float slowingDistance = MOVEMENT_SLOWING_DISTANCE;
    float rampedSpeed = MOVEMENT_MAX_SPEED * distanceToPause / slowingDistance;
    float clippedSpeed = MIN(rampedSpeed, MOVEMENT_MAX_SPEED);
    GLKVector2 desiredVelocity = GLKVector2MultiplyScalar(GLKVector2Normalize(targetOffset), clippedSpeed);
    GLKVector2 steering = GLKVector2Subtract(desiredVelocity, velocity);
    if (GLKVector2Length(steering) != 0.0f) {
        steering = GLKVector2MultiplyScalar(GLKVector2Normalize(steering), MOVEMENT_STEERING_SPEED);
    }
    velocity = GLKVector2Add(velocity, steering);
    if (GLKVector2Length(velocity) > MOVEMENT_MAX_SPEED) {
        velocity = GLKVector2MultiplyScalar(GLKVector2Normalize(velocity), MOVEMENT_MAX_SPEED);
    }
    position = GLKVector2Add(position, velocity);
}

- (void) decreaseMovement {
    float speed = GLKVector2Length(velocity);
    if (speed <= 0.0f) {
        return;
    }
    velocity = GLKVector2MultiplyScalar(GLKVector2Normalize(velocity), speed * (1.0f - MOVEMENT_STEERING_SPEED));
    position = GLKVector2Add(position, velocity);
}

- (void) updateAngle {
    AnglePoint anglePoint = anglePoints[movementType][userPhotoIndex][anglePointIndex];
    float destAngle = [self calculateAngle:anglePoint];
	if (ABS(angle - destAngle) > M_PI) {
        angle += M_PI * 2.0f * (angle < destAngle ? 1.0f : -1.0f);
    }
    float oldDestAngle = [self calculateAngle:oldDestAnglePoint];
	if (ABS(oldDestAngle - destAngle) > M_PI) {
        oldDestAngle += M_PI * 2.0f * (oldDestAngle < destAngle ? 1.0f : -1.0f);
    }
	angle = destAngle + ((cos(angleTransition * M_PI) + 1.0f) * 0.5f * (oldDestAngle - destAngle));
    angleTransition = MIN(angleTransition + (ANGLE_TRANSITION_SPEED * anglePoint.angleSpeed), 1.0f);
}

- (float) calculateAngle:(AnglePoint)anglePoint {
    if (anglePoint.type == ANGLE_TYPE_LOOK_IN) {
        return anglePoint.lookIn;
    } else {
	    GLKVector2 dir = GLKVector2Subtract(anglePoint.lookAt, position);
	    if (GLKVector2Length(dir) <= 0.0f) {
	        return 0.0f;
	    }
	    GLKVector2 lookAt = GLKVector2Normalize(dir);
	    return atan2f(lookAt.y, lookAt.x) + M_PI * 2.0f - M_PI_2;
    }
}

- (void) updatePath {
    if (splineOffset >= [[self getSplines] getEndOffset]) {
        return;
    }
    float oldSplineOffset = splineOffset;
    splineOffset += MOVEMENT_POINT_SPLINE_INCREASE;
    while ([self distanceToSplinePoint] > MOVEMENT_POINT_DISTANCE_SPLINE) {
        splineOffset -= MOVEMENT_POINT_SPLINE_INCREASE / 2.0f;
        if (splineOffset < oldSplineOffset) {
            splineOffset = oldSplineOffset;
            break;
        }
    }
    while ([self distanceToSplinePoint] < MOVEMENT_POINT_DISTANCE_SPLINE) {
        splineOffset += MOVEMENT_POINT_SPLINE_INCREASE;
    };
    if ([self distanceToEnd] < MOVEMENT_RESUME_DISTANCE) {
	    paused = true;
    }
    if (anglePointIndex < anglePointCount[movementType][userPhotoIndex] - 1 && splineOffset > anglePoints[movementType][userPhotoIndex][anglePointIndex + 1].splineOffset) {
        oldDestAnglePoint = anglePoints[movementType][userPhotoIndex][anglePointIndex];
        angleTransition = 0.0f;
        anglePointIndex = MIN(anglePointIndex + 1, anglePointCount[movementType][userPhotoIndex] - 1);
    }
    if (splineOffset > [[self getSplines] getEndOffset]) {
        splineOffset = [[self getSplines] getEndOffset];
    }
}

- (float) distanceToSplinePoint {
    return GLKVector2Distance(position, [self getTargetPosition]);
}

- (float) distanceToEnd {
    return GLKVector2Distance(position, [self getEndPosition]);
}

- (GLKVector2) getTargetPosition {
    return [[self getSplines] getPosition:splineOffset];
}

- (GLKVector2) getStartPosition {
    return [[self getSplines] getPosition:0.0f];
}

- (GLKVector2) getEndPosition {
    return [[self getSplines] getEndPosition];
}

- (CubicSpline*) getSplines {
    return [self isOnTour] ? tourSplines : walkSplines[userPhotoIndex];
}

- (GLKVector3) getPositionAndAngle {
    return GLKVector3Make(position.x, position.y, angle);
}

- (bool) isPaused {
    return paused;
}

- (bool) isOnTour {
    return movementType == MOVEMENT_DIR_FORWARD_TOUR || movementType == MOVEMENT_DIR_BACKWARDS_TOUR;
}

- (bool) canGoBackwards {
    return paused && userPhotoIndex > 0;
}

- (bool) canGoForwards {
    return paused && userPhotoIndex < userPhotosCount - 1;
}

- (void) setRoomVisibilityCallback:(void(^)(int, int))callback {
    roomVisibilityCallbackHandler = [callback copy];
}

@end
