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

#define MOVEMENT_POINT_DISTANCE 2.0f

#define MOVEMENT_MAX_SPEED 0.1f
#define MOVEMENT_VELOCITY_SPEED 0.005f
#define MOVEMENT_VELOCITY_SPEED_MIN 0.001f

#define ANGLE_MAX_SPEED 0.025f
#define ANGLE_VELOCITY 0.001f

@interface Movement : NSObject {

@private
    GLKVector2 points[MOVEMENT_MAX_POINTS];
    float angles[MOVEMENT_MAX_POINTS];
    int pointsCount;

    int pointIndex;

    GLKVector2 position;
    GLKVector2 movement;
    GLKVector2 velocity;
    
	float angle;
    float angleVelocity;
	float destAngle;
}

- (void) setAngle:(float)a;
- (void) setPosition:(GLKVector2)p;
- (void) setPositionToFirstPoint;

- (void) addPoint:(GLKVector2)p;
- (void) addPoint:(GLKVector2)p angle:(float)a;

- (void) move:(float)speed;

- (GLKVector3) getPositionAndAngle;

@end
