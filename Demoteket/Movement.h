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

#import "Globals.h"
#import "Textures.h"
#import "CubicSpline.h"

#define MOVEMENT_POINT_DISTANCE_NEXT 0.75f
#define MOVEMENT_POINT_DISTANCE_PAUSE 0.75f

#define MOVEMENT_POINT_DISTANCE_SPLINE 0.5f
#define MOVEMENT_POINT_SPLINE_INCREASE 0.01f

#define MOVEMENT_MAX_SPEED 0.03f
#define MOVEMENT_SLOWING_DISTANCE 2.0f
#define MOVEMENT_STEERING_SPEED 0.001f

#define ANGLE_POINTS_MAX_COUNT 16
#define ANGLE_TRANSITION_SPEED 0.0075f

#define ANGLE_TYPE_LOOK_AT 1
#define ANGLE_TYPE_LOOK_IN 2

#define MOVEMENT_DIR_FORWARD        0
#define MOVEMENT_DIR_BACKWARD       1
#define MOVEMENT_DIR_FORWARD_TOUR   2
#define MOVEMENT_DIR_BACKWARDS_TOUR 3

typedef struct {
    int type;
    float splineOffset;
    GLKVector2 lookAt;
    float lookIn;
    float angleSpeed;
} AnglePoint;

@interface Movement : NSObject {

@private
    CubicSpline *walkSplines[USER_PHOTOS_MAX_COUNT];
    CubicSpline *tourSplines;

    float splineOffset;

    PhotoInfo *userPhotos[USER_PHOTOS_MAX_COUNT];
    int photosCount;
    int userPhotoIndex;
    
    GLKVector2 position;
    GLKVector2 velocity;

    AnglePoint anglePoints[4][USER_PHOTOS_MAX_COUNT][ANGLE_POINTS_MAX_COUNT];
    AnglePoint oldDestAnglePoint;
    int anglePointCount[4][USER_PHOTOS_MAX_COUNT];
    int anglePointIndex;
    
	float angle;
    float angleTransition;
    
    bool paused;
    int movementType;
}

- (void) setAngle:(float)a;
- (void) setPosition:(GLKVector2)p;
- (void) setPositionToFirstPoint;

- (void) addUserPhoto:(PhotoInfo*)photoInfo;
- (void) setUserPhoto:(int)index;

- (void) setWalkPointToLastPoint;

- (void) addWalkPointAbsolute:(GLKVector2)p;
- (void) addWalkPointRelative:(GLKVector2)p;
- (void) addTourPointAbsolute:(GLKVector2)p;
- (void) addTourPointRelative:(GLKVector2)p;

- (void) lookAtRelativeToStart:(GLKVector2)p beginningAt:(float)t;
- (void) lookAtRelativeToEnd:(GLKVector2)p beginningAt:(float)t;
- (void) lookIn:(float)a beginningAt:(float)t;

- (void) move:(float)t;

- (void) setMovement:(int)type;

- (void) startTour;
- (void) stopTour;

- (PhotoInfo*) getCurrentPhoto;

- (bool) isPaused;
- (bool) isOnTour;

- (void) resume;

- (bool) canGoBackwards;
- (bool) canGoForwards;

- (GLKVector3) getPositionAndAngle;

@end
