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

#define MOVEMENT_MAX_POINTS 1024

#define MOVEMENT_POINT_DISTANCE_NEXT 1.0f
#define MOVEMENT_POINT_DISTANCE_PAUSE 0.75f

#define MOVEMENT_MAX_SPEED 0.1f
#define MOVEMENT_SLOWING_DISTANCE 2.0f
#define MOVEMENT_STEERING_SPEED 0.005f

#define ANGLE_TRANSITION_SPEED 0.01f

#define MOVEMENT_TYPE_ANGLE_IN_MOVING_DIR   0
#define MOVEMENT_TYPE_ANGLE_LOOK_AT         1
#define MOVEMENT_TYPE_ANGLE_LOOK_IN         2
#define MOVEMENT_TYPE_ANGLE_LOOK_AT_NO_MOVE 3

typedef struct {
    int type;
    GLKVector2 position;
    GLKVector2 lookAt;
    float lookIn;
    float continueDist;
    bool pause;
} MovementPoint;

@interface Movement : NSObject {

@private
    MovementPoint points[MOVEMENT_MAX_POINTS];
    int pointsCount;

    int pointIndex;

    GLKVector2 position;
    GLKVector2 velocity;
    
	float angle;
    float angleTransition;

    MovementPoint oldDestAnglePoint;
    
    bool paused;
}

- (void) setAngle:(float)a;
- (void) setPosition:(GLKVector2)p;
- (void) setPositionToFirstPoint;

- (void) addPoint:(GLKVector2)p pause:(bool)pause;
- (void) addPoint:(GLKVector2)p lookAt:(GLKVector2)lookAt pause:(bool)pause;
- (void) addPoint:(GLKVector2)p lookIn:(float)a pause:(bool)pause;
- (void) addPointInMovingDirection:(GLKVector2)p pause:(bool)pause;

- (void) addOffsetPoint:(GLKVector2)p pause:(bool)pause;
- (void) addOffsetPoint:(GLKVector2)p lookAt:(GLKVector2)lookAt pause:(bool)pause;
- (void) addOffsetPointInMovingDirection:(GLKVector2)p pause:(bool)pause;

- (void) addOffsetPoint:(GLKVector2)p;
- (void) addOffsetPoint:(GLKVector2)p lookAt:(GLKVector2)lookAt;
- (void) addOffsetPoint:(GLKVector2)p lookIn:(float)a;
- (void) addOffsetPointInMovingDirection:(GLKVector2)p;

- (void) lookAt:(GLKVector2)p continueDistance:(float)dist;

- (void) move:(float)speed;
- (void) resume;

- (bool) isPaused;

- (GLKVector3) getPositionAndAngle;

@end
