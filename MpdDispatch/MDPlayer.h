//
//  Player.h
//  MpdDispatch
//
//  Created by kernel on 6/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "MDHelper.h"
#import "MDSong.h"
#import "MDStatus.h"
#import "MDPlaylist.h"

@interface MDPlayer : MDHelper
- (BOOL)stop;
- (BOOL)play;
- (BOOL)pause;
- (BOOL)toggle;
- (BOOL)next;
- (BOOL)prev;
- (BOOL)addURI:(NSString *)uri;
- (BOOL)addURI:(NSString *)uri toPosition:(NSUInteger)pos;
- (BOOL)removeSong:(MDSong *)song;
- (BOOL)loadAndPlayURI:(NSString *)uri;
- (BOOL)playSong:(MDSong *)song;
- (void)update;
- (BOOL)clearQueue;
- (BOOL)removeFromQueue:(MDSong *)song;
- (BOOL)moveSong:(MDSong *)song toPosition:(NSUInteger)pos;
- (BOOL)setVolume:(NSUInteger)volume;
- (void)setShouldRepeat:(BOOL)mode;
- (void)setShouldPlayRandom:(BOOL)mode;
- (void)seekTo:(NSUInteger)duration;

// Playlists-related methods.
- (BOOL)savePlaylistWithName:(NSString *)name;
- (BOOL)loadPlaylist:(MDPlaylist *)playlist;
//- (BOOL)clearPlaylistWithName:(NSString *)name;
- (NSArray *)loadPlaylistsLists;

@property (strong, nonatomic, readonly) NSArray *queue, *playlists;
@property (strong, nonatomic, readonly) MDStatus *status;
@property (strong, nonatomic, readonly) MDSong *currentSong;
@property (assign, nonatomic, readonly) BOOL repeat, random;
@property (assign, nonatomic, readonly) NSUInteger volume;
// seek. Duration progress for currentSong.
@property (assign, nonatomic, readonly) NSUInteger seek, kBitRate;
@property (assign, nonatomic) BOOL autoplay;
@property (assign, nonatomic, readonly, getter=isPlaying) BOOL playing;
@end
