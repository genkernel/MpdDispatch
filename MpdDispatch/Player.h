//
//  Player.h
//  MpdDispatch
//
//  Created by kernel on 6/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "Helper.h"
#import "Song.h"
#import "Status.h"

@interface Player : Helper
- (BOOL)stop;
- (BOOL)play;
- (BOOL)pause;
- (BOOL)toggle;
- (BOOL)next;
- (BOOL)prev;
- (BOOL)addURI:(NSString *)uri;
- (Song *)currentSong;
- (Status *)status;
- (BOOL)loadAndPlayURI:(NSString *)uri;

@property (strong, nonatomic, readonly) NSArray *queue;
@end
