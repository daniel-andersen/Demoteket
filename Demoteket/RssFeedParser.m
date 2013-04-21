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

#import "RssFeedParser.h"
#import "NSString+HTML.h"

@implementation RssFeedParser

- (void) loadFeed:(NSURL*)url successCallback:(void(^)())successCallback errorCallback:(void(^)())errorCallback {
    NSLog(@"Asynchronously loading feed");
    [NSURLConnection sendAsynchronousRequest:[[NSMutableURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [self backupFeed];
        if (error) {
            if (errorCallback != NULL) {
                errorCallback();
            }
            return;
        }
        NSLog(@"Feed fetched!");
        feed = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self findElements];
        if (successCallback != NULL) {
	        successCallback();
        }
    }];
}

- (void) backupFeed {
    oldCount = count;
    for (int i = 0; i < USER_PHOTOS_COUNT; i++) {
        descriptions[1][i] = descriptions[0][i];
        titles[1][i] = titles[0][i];
        images[1][i] = images[0][i];
        links[1][i] = links[0][i];
    }
}

- (bool) hasChanges {
    if (count != oldCount) {
        return true;
    }
    for (int i = 0; i < count; i++) {
        if ([descriptions[0][i] compare:descriptions[1][i]] != NSOrderedSame) {
            return true;
        }
        if ([titles[0][i] compare:titles[1][i]] != NSOrderedSame) {
            return true;
        }
        if ([images[0][i] compare:images[1][i]] != NSOrderedSame) {
            return true;
        }
        if ([links[0][i] compare:links[1][i]] != NSOrderedSame) {
            return true;
        }
    }
    return false;
}

- (int) photoCount {
    return count;
}

- (bool) isPhoto:(NSString*)url {
    return url != NULL ? [url hasSuffix:@".png"] || [url hasSuffix:@".jpg"] || [url hasSuffix:@".jpeg"] : false;
}

- (NSString*) getDescription:(int)index {
    return index < count ? descriptions[0][index] : NULL;
}

- (NSString*) getTitle:(int)index {
    return index < count ? titles[0][index] : NULL;
}

- (NSString*) getLink:(int)index {
    return index < count ? links[0][index] : NULL;
}

- (NSString*) getImage:(int)index {
    return index < count ? images[0][index] : NULL;
}

- (void) findElements {
    count = 0;
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\<item\\>(.*?)\\<\\/item\\>" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
    if (error) {
        return;
    }
    NSArray *results = [regex matchesInString:feed options:0 range:NSMakeRange(0, [feed length])];
    for (NSTextCheckingResult *result in results) {
        if (result.numberOfRanges != 2) {
            continue;
        }
        NSString* capture = [feed substringWithRange:[result rangeAtIndex:1]];
        if (![self isCorrectCategory:capture]) {
            continue;
        }
        images[0][count] = [[self findImage:count fromText:capture] stringByDecodingHTMLEntities];
        titles[0][count] = [[self findTitle:count fromText:capture] stringByDecodingHTMLEntities];
        descriptions[0][count] = [[self findDescription:count fromText:capture] stringByDecodingHTMLEntities];
        links[0][count] = [[self findLink:count fromText:capture] stringByDecodingHTMLEntities];
        if ([self isPhoto:images[0][count]]) {
	        count++;
        }
        if (count >= USER_PHOTOS_COUNT) {
            return;
        }
    }
}

- (BOOL)isCorrectCategory:(NSString*)text {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<category\\>\\<\\!\\[CDATA\\[(.*?)\\]\\]\\>\\<\\/category\\>" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
    if (error) {
        return false;
    }
    NSArray *results = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    for (NSTextCheckingResult *result in results) {
        NSString* capture = [text substringWithRange:[result rangeAtIndex:1]];
        if ([@"værker" isEqualToString:[capture lowercaseString]]) {
            return true;
        }
    }
    return false;
}

- (NSString*) findTitle:(int)index fromText:(NSString*)text {
    return [self findElement:@"\\<title\\>(.*?)\\<\\/title\\>" fromText:text];
}

- (NSString*) findDescription:(int)index fromText:(NSString*)text {
    return [self findElement:@"<description\\>\\<\\!\\[CDATA\\[(.*?)\\]\\]\\>\\<\\/description\\>" fromText:text];
}

- (NSString*) findImage:(int)index fromText:(NSString*)text {
    return [self findElement:@"<description\\>.*?\\[CDATA\\[.*?src=\"(.*?)\"" fromText:text];
}

- (NSString*) findLink:(int)index fromText:(NSString*)text {
    return [self findElement:@"\\<guid.*?\\>(.*?)\\<\\/guid\\>" fromText:text];
}

- (NSString*) findElement:(NSString*)pattern fromText:(NSString*)text {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionDotMatchesLineSeparators error:&error];
    if (error) {
        return NULL;
    }
    NSArray *results = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    for (NSTextCheckingResult *result in results) {
        for (int captureIndex = 1; captureIndex < result.numberOfRanges; captureIndex++) {
            return [text substringWithRange:[result rangeAtIndex:captureIndex]];
        }
    }
    return NULL;
}

@end
