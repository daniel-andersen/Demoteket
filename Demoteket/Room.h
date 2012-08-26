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

#import "Quads.h"
#import "Globals.h"
#import "Movement.h"

#define ROOM_MAX_SIZE 16

#define PHOTOS_MAX_COUNT 32
#define WALL_COUNT 6
#define LIGHT_MAX_COUNT 32

#define ROOM_HEIGHT 5.0f
#define LIGHTS_HEIGHT (ROOM_HEIGHT * 1.5f)

#define BLOCK_SIZE 1.5f

#define WALL_DEPTH (BLOCK_SIZE * 0.05f)

#define PILLAR_WIDTH (BLOCK_SIZE * 1.0f)
#define PILLAR_DEPTH (BLOCK_SIZE * 0.05f)

#define PHOTO_DEPTH (BLOCK_SIZE / 30.0f)

extern const float ROOM_OFFSET_X[];
extern const float ROOM_OFFSET_Z[];

@interface Room : NSObject {
@private
    char tiles[ROOM_MAX_SIZE][ROOM_MAX_SIZE];
    int stripNumber;

    bool isVisible;
    
    int roomNumber;

    Quads *floor;

    Quads *lights[LIGHT_MAX_COUNT];
    int lightsCount;
    
    Quads *walls[WALL_COUNT];
    Quads *wallsBorder;

    Quads *photos[PHOTOS_MAX_COUNT];
    int photosCount;

    Quads *photosBorder;
    
    Quads *pillars;
    Quads *pillarsBorder;
}

- (void) initializeRoomNumber:(int)number;
- (void) trashRoom;

- (void) render;
- (void) renderFloor;

@end
