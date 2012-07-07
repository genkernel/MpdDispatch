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
- (BOOL)loadAndPlayURI:(NSString *)uri;
- (BOOL)playSong:(Song *)song;
- (void)update;

@property (strong, nonatomic, readonly) NSArray *queue;
@property (strong, nonatomic, readonly) Status *status;
@property (strong, nonatomic, readonly) Song *currentSong;
@property (assign, nonatomic) BOOL repeat, random;
@property (assign, nonatomic) NSUInteger volume;
// seek. Duration progress for currentSong.
@property (assign, nonatomic) NSUInteger seek;
@property (assign, nonatomic) BOOL autoplay;
@property (assign, nonatomic, readonly, getter=isPlaying) BOOL playing;
@end
