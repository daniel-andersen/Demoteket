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

@implementation RssFeedParser

- (void) loadFeed:(NSURL*)url callback:(void(^)())callback {
    NSLog(@"Asynchronously loading feed");
    [NSURLConnection sendAsynchronousRequest:[[NSMutableURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSLog(@"Feed fetched!");
        feed = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self findDescriptions];
        [self findTitles];
        [self findLinks];
        [self findImages];
        if (callback != NULL) {
	        callback();
        }
    }];
}

- (bool) isPhoto:(int)index {
    NSString *image = [self getImage:index];
    return image != NULL ? [image hasSuffix:@".png"] || [image hasSuffix:@".jpg"] || [image hasSuffix:@".jpeg"] || [image hasSuffix:@".gif"] : false;
}

- (NSString*) getDescription:(int)index {
    return index < descriptionCount ? descriptions[index] : NULL;
}

- (NSString*) getTitle:(int)index {
    return index < titleCount ? titles[index] : NULL;
}

- (NSString*) getLink:(int)index {
    return index < linkCount ? links[index] : NULL;
}

- (NSString*) getImage:(int)index {
    return index < imageCount ? images[index] : NULL;
}

- (NSString*) findImages {
    imageCount = 0;
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\<item\\>.*?\\<description\\>.*?\\[CDATA\\[.*?src=\"(.*?)\"" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
    if (error) {
        return NULL;
    }
    NSArray *results = [regex matchesInString:feed options:0 range:NSMakeRange(0, [feed length])];
    for (NSTextCheckingResult *result in results) {
        for (int captureIndex = 1; captureIndex < result.numberOfRanges; captureIndex++) {
            NSString* capture = [feed substringWithRange:[result rangeAtIndex:captureIndex]];
            images[imageCount++] = capture;
        }
    }
    return NULL;
}

- (NSString*) findDescriptions {
    descriptionCount = 0;
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\<item\\>.*?\\<description\\>\\<\\!\\[CDATA\\[(.*?)\\]\\]\\>\\<\\/description\\>" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
    if (error) {
        return NULL;
    }
    NSArray *results = [regex matchesInString:feed options:0 range:NSMakeRange(0, [feed length])];
    for (NSTextCheckingResult *result in results) {
        for (int captureIndex = 1; captureIndex < result.numberOfRanges; captureIndex++) {
            NSString* capture = [feed substringWithRange:[result rangeAtIndex:captureIndex]];
            descriptions[descriptionCount++] = capture;
        }
    }
    return NULL;
}

- (NSString*) findTitles {
    titleCount = 0;
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\<item\\>.*?\\<title\\>(.*?)\\<\\/title\\>" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
    if (error) {
        return NULL;
    }
    NSArray *results = [regex matchesInString:feed options:0 range:NSMakeRange(0, [feed length])];
    for (NSTextCheckingResult *result in results) {
        for (int captureIndex = 1; captureIndex < result.numberOfRanges; captureIndex++) {
            NSString* capture = [feed substringWithRange:[result rangeAtIndex:captureIndex]];
            titles[titleCount++] = capture;
        }
    }
    return NULL;
}

- (NSString*) findLinks {
    linkCount = 0;
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\<item\\>.*?\\<guid.*?\\>(.*?)\\<\\/guid\\>" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
    if (error) {
        return NULL;
    }
    NSArray *results = [regex matchesInString:feed options:0 range:NSMakeRange(0, [feed length])];
    for (NSTextCheckingResult *result in results) {
        for (int captureIndex = 1; captureIndex < result.numberOfRanges; captureIndex++) {
            NSString* capture = [feed substringWithRange:[result rangeAtIndex:captureIndex]];
            links[linkCount++] = capture;
        }
    }
    return NULL;
}

@end
