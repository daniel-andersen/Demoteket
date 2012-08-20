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

static float ROOM_OFFSET_X[] = {0, BLOCK_SIZE * -4 - WALL_DEPTH, 0, 0, 0};
static float ROOM_OFFSET_Z[] = {0, BLOCK_SIZE * -2,              0, 0, 0};

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
        [self addStrip:@"+---+"];
        [self addStrip:@"d   |"];
        [self addStrip:@"+   |"];
        [self addStrip:@"|   |"];
        [self addStrip:@"|  E|"];
        [self addStrip:@"|   |"];
        [self addStrip:@"| D |"];
        [self addStrip:@"|   |"];
        [self addStrip:@"|   |"];
        [self addStrip:@"|   |"];
        [self addStrip:@"|   |"];
        [self addStrip:@"+---+"];
	}
    if (number == 1) {
        [self addStrip:@"+---+"];
        [self addStrip:@"|   |"];
        [self addStrip:@"|   +"];
        [self addStrip:@"|    "];
        [self addStrip:@"|   +"];
        [self addStrip:@"|   |"];
        [self addStrip:@"|   |"];
        [self addStrip:@"|   |"];
        [self addStrip:@"|   |"];
        [self addStrip:@"|   |"];
        [self addStrip:@"|   |"];
        [self addStrip:@"+---+"];
	}
}

- (void) addStrip:(NSString *)strip {
    for (int i = 0; i < [strip length]; i++) {
        tiles[stripNumber][i] = [strip characterAtIndex:i];
    }
    stripNumber++;
}

- (void) createGeometrics {
    photosCount = 0;

    for (int i = 0; i < PHOTOS_MAX_COUNT; i++) {
        photos[i] = NULL;
        photosLight[i] = NULL;
    }

    walls = [[Quads alloc] init];
    [walls beginWithTexture:[textures getWallTexture:0]];

    pillars = [[Quads alloc] init];
    [pillars beginWithTexture:[textures getPillarTexture:0]];

    pillarsBorder = [[Quads alloc] init];
    [pillarsBorder beginWithTexture:[textures getPillarBorderTexture:0] color:GLKVector4Make(0.7f, 0.7f, 0.7f, 1.0f)];

    photosBorder = [[Quads alloc] init];
    [photosBorder beginWithColor:GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f)];

    for (int i = 0; i < ROOM_MAX_SIZE; i++) {
        for (int j = 0; j < ROOM_MAX_SIZE; j++) {
            if (tiles[i][j] == 'X' || tiles[i][j] == ' ') {
                continue;
            }
            float x1 = ROOM_OFFSET_X[roomNumber] + ((float) j * BLOCK_SIZE);
            float z1 = ROOM_OFFSET_Z[roomNumber] + ((float) i * BLOCK_SIZE);
            float x2 = x1 + BLOCK_SIZE;
            float z2 = z1 + BLOCK_SIZE;
            float centerX = x1 + (BLOCK_SIZE / 2);
            float centerZ = z1 + (BLOCK_SIZE / 2);
            if (tiles[i][j] == '-') {
                if ([self isOutsideRoomX:j y:i - 1]) {
	                [self addWallGridX:j gridY:i x:centerX z:centerZ angle:0.0f];
                } else {
	                [self addWallGridX:j gridY:i x:centerX z:centerZ angle:M_PI];
                }
            }
            if (tiles[i][j] == '|') {
                if ([self isOutsideRoomX:j - 1 y:i]) {
	                [self addWallGridX:j gridY:i x:centerX z:centerZ angle:-M_PI_2];
                } else {
	                [self addWallGridX:j gridY:i x:centerX z:centerZ angle: M_PI_2];
                }
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
            if (tiles[i][j] >= 'A' && tiles[i][j] <= 'Z') {
                float angle = 2.0f * 3.14f * (float) (((int) tiles[i][j] - (int) 'A') / (float) ((int) 'Z' - (int) 'A'));
                [self addPillarGridX:j gridY:i x:centerX z:centerZ angle:angle];
            }
        }
    }
    [walls end];
    [pillars end];
    [pillarsBorder end];
    [photosBorder end];
    for (int i = 0; i < PHOTOS_MAX_COUNT; i++) {
        if (photos[i] != NULL) {
		    [photos[i] end];
		    [photosLight[i] end];
        }
    }
}

- (void) addWallGridX:(int)gridX gridY:(int)gridY x:(float)x z:(float)z angle:(float)angle {
    int type = arc4random() % PHOTOS_COUNT;
    tiles[gridY][gridX] = type;
    [self addWallType:type x:x z:z angle:angle];
}

- (void) addWallType:(int)type x:(float)x z:(float)z angle:(float)angle {
    float x1 = x - cos(angle) * BLOCK_SIZE;
    float z1 = z - sin(angle) * BLOCK_SIZE;
    float x2 = x + cos(angle) * BLOCK_SIZE;
    float z2 = z + sin(angle) * BLOCK_SIZE;
    [walls addQuadVerticalX1:x1 y1:0.0f z1:z1 x2:x2 y2:ROOM_HEIGHT z2:z2];
    [self addPhotosLight:type x:x z:z angle:angle];
    [self addPhotosType:type x:x z:z angle:angle];
}

- (void) addPillarGridX:(int)gridX gridY:(int)gridY x:(float)x z:(float)z angle:(float)angle {
    int type = arc4random() % PHOTOS_COUNT;
    [self addPillarType:type x:x z:z angle:angle];
}

- (void) addPillarType:(int)type x:(float)x z:(float)z angle:(float)angle {
    float frontX = x + cos(angle + M_PI_2) * PILLAR_DEPTH;
    float frontZ = z + sin(angle + M_PI_2) * PILLAR_DEPTH;

    float backX = x - cos(angle + M_PI_2) * PILLAR_DEPTH;
    float backZ = z - sin(angle + M_PI_2) * PILLAR_DEPTH;

    float frontX1 = frontX - cos(angle) * PILLAR_WIDTH;
    float frontZ1 = frontZ - sin(angle) * PILLAR_WIDTH;
    float frontX2 = frontX + cos(angle) * PILLAR_WIDTH;
    float frontZ2 = frontZ + sin(angle) * PILLAR_WIDTH;

    float backX1 = backX - cos(angle) * PILLAR_WIDTH;
    float backZ1 = backZ - sin(angle) * PILLAR_WIDTH;
    float backX2 = backX + cos(angle) * PILLAR_WIDTH;
    float backZ2 = backZ + sin(angle) * PILLAR_WIDTH;

    [pillars addQuadVerticalX1:frontX1 y1:0.0f z1:frontZ1 x2:frontX2 y2:ROOM_HEIGHT z2:frontZ2];
    [self addPhotosLight:type x:frontX z:frontZ angle:angle];
    [self addPhotosType:type x:frontX z:frontZ angle:angle];

    [pillars addQuadVerticalX1:backX1 y1:0.0f z1:backZ1 x2:backX2 y2:ROOM_HEIGHT z2:backZ2];
    [self addPhotosLight:type x:backX z:backZ angle:angle + M_PI];
    [self addPhotosType:type x:backX z:backZ angle:angle + M_PI];
    
    [pillarsBorder addQuadVerticalX1:frontX1 y1:0.0f z1:frontZ1 x2:backX1 y2:ROOM_HEIGHT z2:backZ1];
    [pillarsBorder addQuadVerticalX1:frontX2 y1:0.0f z1:frontZ2 x2:backX2 y2:ROOM_HEIGHT z2:backZ2];
}

- (void) addPhotosType:(int)type x:(float)x z:(float)z angle:(float)angle {
    if (type == 0) {
	    [self addPhotoQuadsType:type x:x y:ROOM_HEIGHT / 2.0f z:z width:0.5f height:1.0f horizontalOffset:-0.35f verticalOffset:0.0f angle:angle];
	    [self addPhotoQuadsType:type x:x y:ROOM_HEIGHT / 2.0f z:z width:0.5f height:1.0f horizontalOffset: 0.35f verticalOffset:0.0f angle:angle];
    }
    if (type == 1) {
	    [self addPhotoQuadsType:type x:x y:ROOM_HEIGHT / 2.0f z:z width:0.4f height:0.8f horizontalOffset:0.0f verticalOffset:-0.5f angle:angle];
	    [self addPhotoQuadsType:type x:x y:ROOM_HEIGHT / 2.0f z:z width:0.4f height:0.8f horizontalOffset:0.0f verticalOffset: 0.5f angle:angle];
    }
}

- (void) addPhotoQuadsType:(int)index x:(float)x y:(float)y z:(float)z width:(float)width height:(float)height horizontalOffset:(float)offsetHorz verticalOffset:(float)offsetVert angle:(float)angle {
    if (photos[index] == NULL) {
	    photos[index] = [[Quads alloc] init];
	    [photos[index] beginWithTexture:[textures getPhotosTexture:index]];
    }
    width /= 2.0f;
    height /= 2.0f;
    y += offsetVert;
    float wallX1 = x - cos(angle) * (width + offsetHorz);
    float wallZ1 = z - sin(angle) * (width + offsetHorz);
    float wallX2 = x + cos(angle) * (width - offsetHorz);
    float wallZ2 = z + sin(angle) * (width - offsetHorz);
    float photoX1 = wallX1 + (cos(angle + M_PI_2) * PHOTO_DEPTH);
    float photoZ1 = wallZ1 + (sin(angle + M_PI_2) * PHOTO_DEPTH);
    float photoX2 = wallX2 + (cos(angle + M_PI_2) * PHOTO_DEPTH);
    float photoZ2 = wallZ2 + (sin(angle + M_PI_2) * PHOTO_DEPTH);
    float y1 = y - height;
    float y2 = y + height;

	[photos[index] addQuadVerticalX1:photoX1 y1:y1 z1:photoZ1 x2:photoX2 y2:y2 z2:photoZ2];
	
    [photosBorder addQuadVerticalX1:wallX1 y1:y1 z1:wallZ1 x2:photoX1 y2:y2 z2:photoZ1];
	[photosBorder addQuadVerticalX1:photoX2 y1:y1 z1:photoZ2 x2:wallX2 y2:y2 z2:wallZ2];
	[photosBorder addQuadHorizontalX1:wallX1 z1:wallZ1 x2:wallX2 z2:wallZ2 x3:photoX2 z3:photoZ2 x4:photoX1 z4:photoZ1 y:y1];
	[photosBorder addQuadHorizontalX1:wallX1 z1:wallZ1 x2:photoX1 z2:photoZ1 x3:photoX2 z3:photoZ2 x4:wallX2 z4:wallZ2 y:y2];
}

- (void) addPhotosLight:(int)type x:(float)x z:(float)z angle:(float)angle {
    if (photosLight[type] == NULL) {
	    photosLight[type] = [[Quads alloc] init];
	    [photosLight[type] beginWithTexture:[textures getPhotosLightTexture:type]];
        [photosLight[type] setBlendFuncSrc:GL_SRC_ALPHA dst:GL_ONE];
    }
    float displacement = 0.1f;
    float x1 = x - cos(angle) * BLOCK_SIZE + cos(angle + M_PI_2) * displacement;
    float z1 = z - sin(angle) * BLOCK_SIZE + sin(angle + M_PI_2) * displacement;
    float x2 = x + cos(angle) * BLOCK_SIZE + cos(angle + M_PI_2) * displacement;
    float z2 = z + sin(angle) * BLOCK_SIZE + sin(angle + M_PI_2) * displacement;
    [photosLight[type] addQuadVerticalX1:x1 y1:0.0f z1:z1 x2:x2 y2:ROOM_HEIGHT z2:z2];
}

- (int) getCornerTypeX:(int)x y:(int)y {
    char x1 = x > 0 ? tiles[y][x - 1] : 'X';
    char y1 = y > 0 ? tiles[y - 1][x] : 'X';
    char x2 = x < ROOM_MAX_SIZE - 1 ? tiles[y][x + 1] : 'X';
    char y2 = y < ROOM_MAX_SIZE - 1 ? tiles[y + 1][x] : 'X';
    int type = 0;
    type += [self isCharWallBrick:x1] ? 1 : 0;
    type += [self isCharWallBrick:y1] ? 2 : 0;
    type += [self isCharWallBrick:x2] ? 4 : 0;
    type += [self isCharWallBrick:y2] ? 8 : 0;
    return type;
}

- (int) getDoorDirectionX:(int)x y:(int)y {
    return ![self isWallX:x - 1 y:y] || ![self isWallX:x + 1 y:y] ? 0 : 1;
}

- (bool) isOutsideRoomX:(int)x y:(int)y {
    return x < 0 || y < 0 || x >= ROOM_MAX_SIZE || y >= ROOM_MAX_SIZE || tiles[y][x] == 'X';
}

- (bool) isWallX:(int)x y:(int)y {
    return x >= 0 && y >= 0 && x < ROOM_MAX_SIZE && y < ROOM_MAX_SIZE && [self isCharWallBrick:tiles[y][x]];
}

- (bool) isCharWallBrick:(char)ch {
    return ch == '|' || ch == '-' || ch == '+';
}

- (void) render {
    [walls render];
	[pillars render];
	[pillarsBorder render];
    glDepthMask(false);
    glDepthFunc(GL_LEQUAL);
    for (int i = 0; i < PHOTOS_MAX_COUNT; i++) {
        if (photos[i] != NULL) {
		    [photosLight[i] render];
        }
    }
    glDepthFunc(GL_LESS);
    glDepthMask(true);
    for (int i = 0; i < PHOTOS_MAX_COUNT; i++) {
        if (photos[i] != NULL) {
		    [photos[i] render];
        }
    }
    [photosBorder render];
}

@end
