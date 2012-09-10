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

#define MOVEMENT_RESUME_DISTANCE 1.5f

#define MOVEMENT_POINT_DISTANCE_SPLINE 0.5f
#define MOVEMENT_POINT_SPLINE_INCREASE 0.01f

#define MOVEMENT_MAX_SPEED 0.03f
#define MOVEMENT_SLOWING_DISTANCE 2.0f
#define MOVEMENT_STEERING_SPEED 0.001f

#define ANGLE_POINTS_MAX_COUNT 16
#define ANGLE_TRANSITION_SPEED 0.006f

#define ANGLE_TYPE_LOOK_AT 1
#define ANGLE_TYPE_LOOK_IN 2

#define MOVEMENT_TYPE_FORWARD  0
#define MOVEMENT_TYPE_BACKWARD 1

#define ROOM_VISIBILITY_MAX_COUNT 8

#define ROOM_VISIBILITY_TYPE_SHOW 0
#define ROOM_VISIBILITY_TYPE_HIDE 1

typedef struct {
    int type;
    float splineOffset;
    GLKVector2 lookAt;
    float lookIn;
    float angleSpeed;
    float continueDelay;
} AnglePoint;

typedef struct {
    int type;
    float splineOffset;
    int roomIndex;
} RoomVisibility;

@interface Movement : NSObject {

@private
    CubicSpline *splines[2][USER_PHOTOS_MAX_COUNT];

    float splineOffset;

    PhotoInfo *userPhotos[USER_PHOTOS_MAX_COUNT];
    int photosCount;
    int userPhotoIndex;
    
    GLKVector2 position;
    GLKVector2 velocity;

    AnglePoint anglePoints[2][USER_PHOTOS_MAX_COUNT][ANGLE_POINTS_MAX_COUNT];
    AnglePoint oldDestAnglePoint;
    int anglePointCount[2][USER_PHOTOS_MAX_COUNT];
    int anglePointIndex;
    
    RoomVisibility roomVisibility[2][USER_PHOTOS_MAX_COUNT][ROOM_VISIBILITY_MAX_COUNT];
    int roomVisibilityCount[2][USER_PHOTOS_MAX_COUNT];
    int roomVisibilityIndex;
    void (^roomVisibilityCallbackHandler)(int, int);
    
	float angle;
    float angleTransition;
    
    bool paused;
    int movementType;
    bool tourMode;
}

- (void) setAngle:(float)a;
- (void) setPosition:(GLKVector2)p;
- (void) setPositionToFirstPoint;

- (void) addUserPhoto:(PhotoInfo*)photoInfo;
- (void) setUserPhoto:(int)index;

- (void) setPointToLastPoint;

- (void) addPointRelativeToLastPoint:(GLKVector2)p;
- (void) addPointRelativeToLastPoint:(GLKVector2)p ofMovementType:(int)type;
- (void) addPointAbsolute:(GLKVector2)p;
- (void) addPointRelative:(GLKVector2)p;

- (void) lookAtAbsolute:(GLKVector2)p beginningAt:(float)t withDelay:(float)delay;
- (void) lookAtRelativeToStart:(GLKVector2)p beginningAt:(float)t withDelay:(float)delay;
- (void) lookAtRelativeToEnd:(GLKVector2)p beginningAt:(float)t withDelay:(float)delay;
- (void) lookIn:(float)a beginningAt:(float)t withDelay:(float)delay;

- (void) setRoomVisibilityOne:(bool)v1 two:(bool)v2 three:(bool)v3 four:(bool)v4 beginningAt:(float)t;

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

- (void) setRoomVisibilityCallback:(void(^)(int, int))callback;

@end
