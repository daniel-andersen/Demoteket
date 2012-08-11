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

#import "Room.h"
#import "Globals.h"

@implementation Room

static int ROOM_OFFSET_X[] = {0, 0, 0, 0, 0};
static int ROOM_OFFSET_Z[] = {0, 0, 0, 0, 0};

- (id) init {
    if (self = [super init]) {
        isVisible = false;
    }
    return self;
}

- (void) initializeRoomNumber:(int)number {
    NSLog(@"Initializing room number %i", number);
    [self createRoomNumber:number];
    [self createGeometrics];
    isVisible = true;
}

- (void) trashRoom {
    NSLog(@"TODO!");
    isVisible = false;
}

- (void) createRoomNumber:(int)number {
    roomNumber = number;
    stripNumber = 0;
    for (int i = 0; i < ROOM_MAX_SIZE; i++) {
        for (int j = 0; j < ROOM_MAX_SIZE; j++) {
            tiles[i][j] = 'X';
        }
    }
    if (number == 0) {
        [self addStrip:@"+--------+"];
        [self addStrip:@"d        |"];
        [self addStrip:@"d        |"];
        [self addStrip:@"+   +-+  |"];
        [self addStrip:@"|   | |  |"];
        [self addStrip:@"|   +-+  |"];
        [self addStrip:@"|        |"];
        [self addStrip:@"|        |"];
        [self addStrip:@"|        |"];
        [self addStrip:@"+--------+"];
    }
}

- (void) addStrip:(NSString *)strip {
    for (int i = 0; i < [strip length]; i++) {
        tiles[stripNumber][i] = [strip characterAtIndex:i];
    }
    stripNumber++;
}

- (void) createGeometrics {
    pillarsCount = 0;
    
    floor = [[Quads alloc] init];
    [floor beginWithColor:GLKVector4Make(0.0f, 0.0f, 0.0f, 0.05f)];

    walls = [[Quads alloc] init];
    [walls beginWithTexture:textures.wall];
    
    for (int i = 0; i < ROOM_MAX_SIZE; i++) {
        for (int j = 0; j < ROOM_MAX_SIZE; j++) {
            if (tiles[i][j] == 'X') {
                continue;
            }
            int x1 = ROOM_OFFSET_X[roomNumber] + (j * BLOCK_SIZE);
            int z1 = ROOM_OFFSET_Z[roomNumber] + (i * BLOCK_SIZE);
            int x2 = x1 + BLOCK_SIZE;
            int z2 = z1 + BLOCK_SIZE;
            int centerX = x1 + (BLOCK_SIZE / 2);
            int centerZ = z1 + (BLOCK_SIZE / 2);
            [floor addQuadHorizontalX1:x1 z1:z1 x2:x2 z2:z2 y:0.0f];
            if (tiles[i][j] == ' ') {
                continue;
            }
            if (tiles[i][j] == '-') {
                [walls addQuadVerticalX1:x1 y1:0.0f z1:centerZ x2:x2 y2:ROOM_HEIGHT z2:centerZ];
            }
            if (tiles[i][j] == '|') {
                [walls addQuadVerticalX1:centerX y1:0.0f z1:z1 x2:centerX y2:ROOM_HEIGHT z2:z2];
            }
            if (tiles[i][j] == '+') {
                int type = [self getCornerTypeX:j y:i];
                if ((type & (1 | 4)) == (1 | 4)) {
                    [walls addQuadVerticalX1:x1 y1:0.0f z1:centerZ x2:x2 y2:ROOM_HEIGHT z2:centerZ];
                } else if ((type & 1) == 1) {
                    [walls addQuadVerticalX1:x1 y1:0.0f z1:centerZ x2:centerX y2:ROOM_HEIGHT z2:centerZ];
                } else if ((type & 4) == 4) {
                    [walls addQuadVerticalX1:centerX y1:0.0f z1:centerZ x2:x2 y2:ROOM_HEIGHT z2:centerZ];
                }
                if ((type & (2 | 8)) == (2 | 8)) {
                    [walls addQuadVerticalX1:centerX y1:0.0f z1:z1 x2:centerX y2:ROOM_HEIGHT z2:z2];
                } else if ((type & 2) == 2) {
                    [walls addQuadVerticalX1:centerX y1:0.0f z1:z1 x2:centerX y2:ROOM_HEIGHT z2:centerZ];
                } else if ((type & 8) == 8) {
                    [walls addQuadVerticalX1:centerX y1:0.0f z1:centerZ x2:centerX y2:ROOM_HEIGHT z2:z2];
                }
            }
            if (tiles[i][j] == 'd') {
                // TODO! Door!
            }
        }
    }
    [walls end];
    [floor end];
}

- (int) getCornerTypeX:(int)x y:(int)y {
    char x1 = x > 0 ? tiles[y][x - 1] : 'X';
    char y1 = y > 0 ? tiles[y - 1][x] : 'X';
    char x2 = x < ROOM_MAX_SIZE - 1 ? tiles[y][x + 1] : 'X';
    char y2 = y < ROOM_MAX_SIZE - 1 ? tiles[y + 1][x] : 'X';
    int type = 0;
    type += x1 != 'X' && x1 != ' ' ? 1 : 0;
    type += y1 != 'X' && y1 != ' ' ? 2 : 0;
    type += x2 != 'X' && x2 != ' ' ? 4 : 0;
    type += y2 != 'X' && y2 != ' ' ? 8 : 0;
    return type;
}

- (int) getDoorTypeX:(int)x y:(int)y {
    char x1 = x > 0 ? tiles[y][x - 1] : 'X';
    char x2 = x < ROOM_MAX_SIZE - 1 ? tiles[y][x + 1] : 'X';
    return x1 != 'X' || x1 != ' ' || x2 != 'X' || x2 != ' ' ? 0 : 1;
}

- (void) render {
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    mirrorModelViewMatrix = GLKMatrix4MakeScale(1.0f, -1.0f, 1.0f);
    [self renderObjects];
    
    mirrorModelViewMatrix = GLKMatrix4Identity;
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_DEPTH_BUFFER_BIT);
    
    glkEffect.transform.modelviewMatrix = sceneModelViewMatrix;
    [self renderFloor];
    
    glkEffect.transform.modelviewMatrix = sceneModelViewMatrix;
    [self renderObjects];
    
    glDisable(GL_BLEND);
}

- (void) renderFloor {
    [floor render];
}

- (void) renderObjects {
    [walls render];
    for (int i = 0; i < pillarsCount; i++) {
    	[pillars[i] render];
    }
}

@end
