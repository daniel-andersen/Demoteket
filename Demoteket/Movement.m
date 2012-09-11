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
    movementType = MOVEMENT_TYPE_FORWARD;
    paused = false;
    tourMode = false;
	turnAround = false;

    velocity = GLKVector2Make(0.0f, 0.0f);
    
    angle = 0.0f;
    angleTransition[0] = 0.0f;
    oldDestAnglePoint[0].lookIn = 0.0f;
    oldDestAnglePoint[0].type = ANGLE_TYPE_LOOK_IN;
    angleTransition[1] = 1.0f;
    oldDestAnglePoint[1].lookIn = 0.0f;
    oldDestAnglePoint[1].type = ANGLE_TYPE_LOOK_IN;

    userPhotoIndex = 0;
    anglePointIndex = 0;
    roomVisibilityIndex = 0;
    
    turnAroundSplines = [[CubicSpline alloc] init];
    
    for (int i = 0; i < USER_PHOTOS_COUNT; i++) {
        for (int j = 0; j < 4; j++) {
            splines[j][i] = [[CubicSpline alloc] init];
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
    [self setMovement:MOVEMENT_TYPE_FORWARD];
    splineOffset = 0.0f;
    userPhotoIndex = 8;
    anglePointIndex = 0;
    roomVisibilityIndex = 0;
    position = [self getTargetPosition];
    for (int i = 0; i < USER_PHOTOS_COUNT; i++) {
        anglePoints[0][i][anglePointCount[0][i]].lookAt = GLKVector2Make(-userPhotos[i].position.x, -userPhotos[i].position.y);
        anglePoints[1][i][anglePointCount[1][i]].lookAt = GLKVector2Make(-userPhotos[i].position.x, -userPhotos[i].position.y);
        anglePoints[0][i][anglePointCount[0][i]].splineOffset = 1.0f - (1.0f / (float) (anglePointCount[0][i] + 2));
        anglePoints[1][i][anglePointCount[1][i]].splineOffset = 1.0f - (1.0f / (float) (anglePointCount[1][i] + 2));
        anglePointCount[0][i]++;
        anglePointCount[1][i]++;
    }
}

- (void) setUserPhoto:(int)index {
    userPhotoIndex = index;
    anglePointIndex = 0;
}

- (void) setPointToLastPoint {
    int lastPoint = movementType == MOVEMENT_TYPE_FORWARD ? (userPhotoIndex - 1) : (userPhotoIndex + 1);
    [splines[movementType][userPhotoIndex] addPoint:[splines[movementType][lastPoint] getEndPosition]];
}

- (void) addPointRelativeToLastPoint:(GLKVector2)p {
    int lastPoint = movementType == MOVEMENT_TYPE_FORWARD ? (userPhotoIndex - 1) : (userPhotoIndex + 1);
    [splines[movementType][userPhotoIndex] addPoint:GLKVector2Add([splines[movementType][lastPoint] getEndPosition], p)];
}

- (void) addPointRelativeToLastPoint:(GLKVector2)p ofMovementType:(int)type {
    [splines[movementType][userPhotoIndex] addPoint:GLKVector2Add([splines[type][USER_PHOTOS_COUNT - 1] getEndPosition], p)];
}

- (void) addPointAbsolute:(GLKVector2)p {
    [splines[movementType][userPhotoIndex] addPoint:p];
}

- (void) addPointRelative:(GLKVector2)p {
    [splines[movementType][userPhotoIndex] addOffsetPoint:p];
}

- (void) lookAtAbsolute:(GLKVector2)p beginningAt:(float)t {
    AnglePoint *anglePoint = &anglePoints[movementType][userPhotoIndex][anglePointCount[movementType][userPhotoIndex]];
    anglePoint->type = ANGLE_TYPE_LOOK_AT;
    anglePoint->splineOffset = t;
    anglePoint->lookAt = p;
    anglePoint->angleSpeed = 1.0f;
    anglePointCount[movementType][userPhotoIndex]++;
}

- (void) lookAtRelativeToStart:(GLKVector2)p beginningAt:(float)t {
    AnglePoint *anglePoint = &anglePoints[movementType][userPhotoIndex][anglePointCount[movementType][userPhotoIndex]];
    anglePoint->type = ANGLE_TYPE_LOOK_AT;
    anglePoint->splineOffset = t;
    anglePoint->lookAt = GLKVector2Add(p, [self getStartPosition]);
    anglePoint->angleSpeed = 1.0f;
    anglePointCount[movementType][userPhotoIndex]++;
}

- (void) lookAtRelativeToEnd:(GLKVector2)p beginningAt:(float)t {
    AnglePoint *anglePoint = &anglePoints[movementType][userPhotoIndex][anglePointCount[movementType][userPhotoIndex]];
    anglePoint->type = ANGLE_TYPE_LOOK_AT;
    anglePoint->splineOffset = t;
    anglePoint->lookAt = GLKVector2Add(p, [self getEndPosition]);
    anglePoint->angleSpeed = 1.0f;
    anglePointCount[movementType][userPhotoIndex]++;
}

- (void) lookIn:(float)a beginningAt:(float)t {
    AnglePoint *anglePoint = &anglePoints[movementType][userPhotoIndex][anglePointCount[movementType][userPhotoIndex]];
    anglePoint->type = ANGLE_TYPE_LOOK_IN;
    anglePoint->splineOffset = t;
    anglePoint->lookIn = a;
    anglePoint->angleSpeed = 1.0f;
    anglePointCount[movementType][userPhotoIndex]++;
}

- (void) setRoomVisibilityOne:(bool)v1 two:(bool)v2 three:(bool)v3 four:(bool)v4 beginningAt:(float)t {
    [self setRoomVisibilityNumber:0 visible:v1 beginningAt:t];
    [self setRoomVisibilityNumber:1 visible:v2 beginningAt:t];
    [self setRoomVisibilityNumber:2 visible:v3 beginningAt:t];
    [self setRoomVisibilityNumber:3 visible:v4 beginningAt:t];
}

- (void) setRoomVisibilityNumber:(int)number visible:(bool)v beginningAt:(float)t {
    RoomVisibility *visibility = &roomVisibility[movementType][userPhotoIndex][roomVisibilityCount[movementType][userPhotoIndex]];
    visibility->type = v ? ROOM_VISIBILITY_TYPE_SHOW : ROOM_VISIBILITY_TYPE_HIDE;
    visibility->splineOffset = t;
    visibility->roomIndex = number;
    roomVisibilityCount[movementType][userPhotoIndex]++;
}

- (void) move:(float)t {
    [self updateAngle];
    [self updatePath];
    [self updateMovement];
    [self updateRoomVisibility];
}

- (void) setMovement:(int)type {
    movementType = type;
}

- (void) turnAround {
    [self backupAngle];
    movementType = movementType == MOVEMENT_TYPE_FORWARD ? MOVEMENT_TYPE_BACKWARD : MOVEMENT_TYPE_FORWARD;
    [turnAroundSplines setPoint:0 position:position];
    [turnAroundSplines setPoint:1 position:[splines[movementType][userPhotoIndex] getEndPosition]];
    [turnAroundSplines recalculateSpline];
    turnAround = true;
    paused = true;
}

- (void) startTour {
    tourMode = true;
    [self backupAngle];
    movementType = MOVEMENT_TYPE_FORWARD;
    [self resume];
}

- (void) stopTour {
    [self backupAngleStopTour];
    tourMode = false;
}

- (void) resume {
    paused = false;
    if (![self isOnTour]) {
        [self backupAngleLookIn];
        anglePointIndex = 0;
    } else {
        tourAngleUpdated = false;
    }
    turnAround = false;
    roomVisibilityIndex = 0;
    splineOffset = 0.0f;
    userPhotoIndex = ((movementType == MOVEMENT_TYPE_FORWARD ? userPhotoIndex + 1 : userPhotoIndex - 1) + USER_PHOTOS_COUNT) % USER_PHOTOS_COUNT;
    [[self getSplines] setPoint:0 position:position];
    [[self getSplines] recalculateSpline];
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
    [self decreaseMovement];
    position = GLKVector2Add(position, velocity);
}

- (void) decreaseMovement {
    if ([self isOnTour]) {
        return;
    }
    if (splineOffset >= 1.0f || ABS([self calculateAngle:[self getTargetAnglePoint]] - angle) < 0.3f) {
        return;
    }
    float speed = GLKVector2Length(velocity);
    if (speed <= 0.0f) {
        return;
    }
    velocity = GLKVector2MultiplyScalar(GLKVector2Normalize(velocity), speed * 0.9f);
}

- (void) updateAngle {
    if ([self isOnTour]) {
	    bool lookAtNextPhoto = splineOffset > [[self getSplines] getEndOffset] * ANGLE_TOUR_LOOK_AT_NEXT_PHOTO_PCT;
        if (lookAtNextPhoto && !tourAngleUpdated) {
            [self backupAngle];
        }
    }
	float oldAngleTransition = [self calculateAngleTransition:angleTransition[1] source:[self calculateAngle:oldDestAnglePoint[1]] dest:[self calculateAngle:oldDestAnglePoint[0]]];
	angle = [self calculateAngleTransition:angleTransition[0] source:oldAngleTransition dest:[self calculateAngle:[self getTargetAnglePoint]]];
    angleTransition[0] = MIN(angleTransition[0] + ANGLE_TRANSITION_SPEED, 1.0f);
    angleTransition[1] = MIN(angleTransition[1] + ANGLE_TRANSITION_SPEED, 1.0f);
}

- (float) calculateAngleTransition:(float)t source:(float)source dest:(float)dest {
    if (ABS(dest - source) > M_PI) {
        source += M_PI * 2.0f * (source < dest ? 1.0f : -1.0f);
    }
	return dest + ((cos(t * M_PI) + 1.0f) * 0.5f * (source - dest));
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
	    float a = atan2f(lookAt.y, lookAt.x) + M_PI * 2.0f - M_PI_2;
        if (ABS(angle - a) > M_PI) {
            a += M_PI * 2.0f * (a < angle ? 1.0f : -1.0f);
        }
        return a;
    }
}

- (void) backupAngle {
    oldDestAnglePoint[1] = oldDestAnglePoint[0];
    angleTransition[1] = angleTransition[0];
    if ([self isOnTour]) {
	    oldDestAnglePoint[0] = anglePoints[movementType][userPhotoIndex][anglePointCount[movementType][userPhotoIndex] - 1];
	    angleTransition[0] = 0.0f;
	    tourAngleUpdated = true;
    } else {
        oldDestAnglePoint[0] = [self getTargetAnglePoint];
        angleTransition[0] = 0.0f;
    }
}

- (void) backupAngleLookIn {
    oldDestAnglePoint[1] = oldDestAnglePoint[0];
    angleTransition[1] = angleTransition[0];
    oldDestAnglePoint[0].type = ANGLE_TYPE_LOOK_IN;
    oldDestAnglePoint[0].lookIn = angle;
    angleTransition[0] = 0.0f;
}

- (void) backupAngleStopTour {
    oldDestAnglePoint[1] = oldDestAnglePoint[0];
    angleTransition[1] = angleTransition[0];
    oldDestAnglePoint[0] = [self getTargetAnglePoint];
    angleTransition[0] = 0.0f;
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
        if (splineOffset >= [[self getSplines] getEndOffset]) {
            splineOffset = [[self getSplines] getEndOffset];
            break;
        }
    };
    if ([self distanceToEnd] < MOVEMENT_RESUME_DISTANCE) {
        turnAround = false;
        if (![self isOnTour] && userPhotos[userPhotoIndex].photoTexture.id != trollsAheadLogoTexture.id) {
		    paused = true;
        } else if ([self isOnTour] && userPhotoIndex == 0) {
            [self stopTour];
		    paused = true;
        } else {
	        [self resume];
        }
        return;
    }
    if (![self isOnTour] && !turnAround && anglePointIndex < anglePointCount[movementType][userPhotoIndex] - 1 && splineOffset > anglePoints[movementType][userPhotoIndex][anglePointIndex + 1].splineOffset) {
        [self backupAngle];
        anglePointIndex = MIN(anglePointIndex + 1, anglePointCount[movementType][userPhotoIndex] - 1);
    }
}

- (AnglePoint) getTargetAnglePoint {
    if ([self isOnTour]) {
        bool lookAtNextPhoto = splineOffset > [[self getSplines] getEndOffset] * ANGLE_TOUR_LOOK_AT_NEXT_PHOTO_PCT;
        int index = lookAtNextPhoto ? (userPhotoIndex + 1) % USER_PHOTOS_COUNT : userPhotoIndex;
        int count = anglePointCount[movementType][index];
        return anglePoints[movementType][index][count - 1];
    } else if (turnAround) {
        AnglePoint anglePoint;
        anglePoint.type = ANGLE_TYPE_LOOK_AT;
        anglePoint.lookAt = GLKVector2Make(-userPhotos[userPhotoIndex].position.x, -userPhotos[userPhotoIndex].position.y);
        return anglePoint;
    } else {
	    return anglePoints[movementType][userPhotoIndex][anglePointIndex];
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
    return turnAround ? turnAroundSplines : splines[movementType][userPhotoIndex];
}

- (GLKVector3) getPositionAndAngle {
    return GLKVector3Make(position.x, position.y, angle);
}

- (bool) isPaused {
    return paused;
}

- (bool) isOnTour {
    return tourMode;
}

- (bool) canTurnAround {
    return paused;
}

- (bool) canGoForwards {
    return paused;
}

- (void) setRoomVisibilityCallback:(void(^)(int, int))callback {
    roomVisibilityCallbackHandler = [callback copy];
}

@end
