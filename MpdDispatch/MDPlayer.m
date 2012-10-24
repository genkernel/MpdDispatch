//
//  Player.m
//  MpdDispatch
//
//  Created by kernel on 6/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "MDPlayer.h"
#import "MDHelper+Internals.h"
#import "MDStatus+Internals.h"
#import "MDSong+Internals.h"

@interface MDPlayer()
- (MDStatus *)loadStatus;
- (MDSong *)loadCurentSong;
- (NSArray *)loadQueue;
@property (assign, nonatomic, readonly) int queueVersion, queueLength;
@end

@implementation MDPlayer {
	NSUInteger lastUpdateQueueVersion;
}
@synthesize queue, playlists, status, currentSong, autoplay;
@dynamic volume, repeat, seek, kBitRate;
@dynamic queueVersion, queueLength;
@dynamic playing;

- (id)init {
	self = [super init];
	if (self) {
		lastUpdateQueueVersion = -1;
	}
	return self;
}

- (void)didAuthenticate {
	[super didAuthenticate];
	
	[self update];
}

#pragma mark Private

- (NSArray *)loadQueue {
	NSMutableArray *items = nil;
	BOOL isFullUpdate = nil==self.queue;
	
	if (isFullUpdate) {
		items = [NSMutableArray arrayWithCapacity:self.queueLength];
		
		for (int i=0; i<self.queueLength; i++) {
			struct mpd_song *song = mpd_run_get_queue_song_pos(self.conn, i);
			if (NULL == song) {
				NSLog(@"ERR. Failed to retrieve enqueued song.");
				continue;
			}
			MDSong *newSong = [[MDSong alloc] initWithSongData:song];
			[items addObject:newSong];
		}
		queue = [NSArray arrayWithArray:items];
	} else {
		BOOL completed = mpd_send_queue_changes_meta(self.conn, lastUpdateQueueVersion);
		if (!completed) {
			NSLog(@"ERR. mpd_send_queue_changes_meta");
			return nil;
		}
		items = [NSMutableArray arrayWithArray:self.queue];
		if (items.count > self.queueLength) {
			for (int i=items.count-1; i>=self.queueLength; i--) {
				[items removeObjectAtIndex:i];
			}
		}
		
		struct mpd_song *song = NULL;
		while (NULL != (song = mpd_recv_song(self.conn))) {
			MDSong *updatedSong = [[MDSong alloc] initWithSongData:song];
			if (updatedSong.position < items.count) {
				[items replaceObjectAtIndex:updatedSong.position withObject:updatedSong];
			} else {
				[items addObject:updatedSong];
			}
		}
	}
	
	BOOL completed = mpd_response_finish(self.conn);
	if (!completed) {
		NSLog(@"ERR. mpd_response_finish");
		return nil;
	}
	return items;
}

- (MDSong *)loadCurentSong {
	struct mpd_song *song = mpd_run_current_song(self.conn);
	if (!song) {
		// No current song playing.
		return nil;
	}
	return [[MDSong alloc] initWithSongData:song];
}

- (MDStatus *)loadStatus {
	struct mpd_status *data = mpd_run_status(self.conn);
	if (!data) {
		NSLog(@"mpd_error: %d", mpd_connection_get_error(self.conn));
		return nil;
	}
	return [[MDStatus alloc] initWithStatusData:data];
}

#pragma mark Instance methods

// update
// Requests curentSong, status and playing queue(if queue changed) update.
- (void)update {
	currentSong = [self loadCurentSong];
	status = [self loadStatus];
	
	//assert(nil!=status);
	if (!status) {
		return;
	}
	
	if (self.queueVersion != lastUpdateQueueVersion) {
		queue = [self loadQueue];
		if (!queue) {
			NSLog(@"ERR. Failed to update queue.");
			return;
		}
		lastUpdateQueueVersion = self.queueVersion;
	}
}

- (BOOL)stop {
	BOOL completed = mpd_run_stop(self.conn);
	if (completed) {
		self.status.state = PlayerStateStopped;
	}
	return completed;
}

// play
// Resumes playback.
- (BOOL)play {
	BOOL completed = mpd_run_play(self.conn);
	if (completed) {
		self.status.state = PlayerStatePlaying;
	}
	return completed;
}

- (BOOL)pause {
	BOOL completed = mpd_run_pause(self.conn, true);
	if (completed) {
		self.status.state = PlayerStatePaused;
	}
	return completed;
}

- (BOOL)toggle {
	BOOL completed = mpd_run_toggle_pause(self.conn);
	if (completed) {
		if (PlayerStatePlaying==self.status.state) {
			self.status.state = PlayerStatePaused;
		} else if (PlayerStatePaused==self.status.state) {
			self.status.state = PlayerStatePlaying;
		}
	}
	return completed;
}

- (BOOL)next {
	BOOL completed = mpd_run_next(self.conn);
	if (!completed) {
		return NO;
	}
	if (self.autoplay && PlayerStatePlaying!=self.status.state) {
		completed = [self play];
	}
	return completed;
}

- (BOOL)prev {
	BOOL completed = mpd_run_previous(self.conn);
	if (!completed) {
		return NO;
	}
	if (self.autoplay && PlayerStatePlaying!=self.status.state) {
		completed = [self play];
	}
	return completed;
}

- (BOOL)addURI:(NSString *)uri {
	return mpd_run_add(self.conn, uri.UTF8String);
}

- (BOOL)addURI:(NSString *)uri toPosition:(NSUInteger)pos {
	return mpd_run_add_id_to(self.conn, uri.UTF8String, pos);
}

- (BOOL)removeSong:(MDSong *)song {
	return mpd_run_delete_id(self.conn, song.uid);
}

// loadAndPlayURI:
// Clears current queue, appends new song and starts playback.
- (BOOL)loadAndPlayURI:(NSString *)uri {
	BOOL completed = mpd_run_clear(self.conn) && mpd_run_add(self.conn, [uri UTF8String]) && mpd_run_play(self.conn);
	
	enum mpd_error code = mpd_connection_get_error(self.conn);
	completed = MPD_ERROR_SUCCESS==code;
	if (!completed) {
		NSLog(@"mpd_error: %d", code);
	}
	return completed;
}

- (BOOL)clearQueue {
	BOOL completed = mpd_run_clear(self.conn);
	if (completed) {
		queue = nil;
		currentSong = nil;
		self.status.state = PlayerStateStopped;
	}
	return completed;
}

- (BOOL)removeFromQueue:(MDSong *)song {
	BOOL completed = mpd_run_delete_id(self.conn, song.uid);
	if (completed) {
		NSMutableArray *items = [NSMutableArray arrayWithArray:self.queue];
		[items removeObjectAtIndex:song.position];
		// Update subsequent songs positions.
		for (int i=song.position; i<items.count; i++) {
			MDSong *nextSong = items[i];
			//nextSong.data->pos = i;
			nextSong.data->pos--;
		}
		queue = [NSArray arrayWithArray:items];
	}
	return completed;
}

- (BOOL)moveSong:(MDSong *)song toPosition:(NSUInteger)pos {
	if (pos == song.position) {
		NSLog(@"Song is already at the position.");
		return NO;
	}
	if (pos >= self.queue.count) {
		NSLog(@"Invalid move position specified.");
		return NO;
	}
	
	BOOL completed = mpd_run_move_id(self.conn, song.uid, pos);
	if (completed) {
		// Update songs positions.
		BOOL added = NO;
		NSMutableArray *items = [NSMutableArray arrayWithCapacity:self.queue.count];
		for (int i=0, p=0; i<self.queue.count;) {
			MDSong *otherSong = self.queue[i];
			
			if (otherSong!=song) {
				if (p==pos) {
					song.data->pos = p++;
					[items addObject:song];
					added = YES;
					continue;
				}
				otherSong.data->pos = p++;
				[items addObject:otherSong];
			}
			i++;
		}
		if (!added) {
			song.data->pos = pos;
			[items addObject:song];
		}
		queue = [NSArray arrayWithArray:items];
	}
	return completed;
}

- (BOOL)playSong:(MDSong *)song {
	if (song.position >= self.queue.count) {
		return NO;
	}
	BOOL completed = mpd_run_play_id(self.conn, song.uid);
	if (completed) {
		currentSong = song;
		self.status.state = PlayerStatePlaying;
	}
	return completed;
}

#pragma mark Playlists

// Saves current queue to playlist.
- (BOOL)savePlaylistWithName:(NSString *)name {
	BOOL completed = mpd_run_save(self.conn, name.UTF8String);
	return completed;
}

- (BOOL)loadPlaylist:(MDPlaylist *)playlist {
	NSString *name = playlist.pathName;
	BOOL completed = mpd_run_load(self.conn, name.UTF8String);
	return completed;
}

/*- (BOOL)clearPlaylistWithName:(NSString *)name {
	BOOL completed = mpd_run_playlist_clear(self.conn, name.UTF8String);
	return completed;
}*/

- (NSArray *)loadPlaylistsLists {
	BOOL completed = mpd_send_list_playlists(self.conn);
	if (!completed) {
		NSLog(@"mpd_error: %d", mpd_connection_get_error(self.conn));
		return nil;
	}
	
	NSMutableArray *items = [NSMutableArray array];
	
	struct mpd_playlist *playlist = NULL;
	while ((playlist = mpd_recv_playlist(self.conn))) {
		MDPlaylist *newPlaylist = [[MDPlaylist alloc] initWithPlaylistData:playlist];
		[items addObject:newPlaylist];
		
		// TODO
		//mpd_send_list_playlist_meta
	}
	mpd_response_finish(self.conn);
	
	BOOL connected = MPD_ERROR_SUCCESS==mpd_connection_get_error(self.conn);
	if (!connected) {
		return nil;
	}
	playlists = [NSArray arrayWithArray:items];
	return playlists;
}

#pragma mark Properties

- (BOOL)repeat {
	return mpd_status_get_repeat(self.status.data);
}

- (void)setShouldRepeat:(BOOL)mode {
	if (mode == self.repeat) {
		return;
	}
	BOOL completed = mpd_run_repeat(self.conn, mode);
	if (!completed) {
		NSLog(@"ERR. mpd_run_repeat");
		return;
	}
	self.status.data->repeat = mode;
}

- (BOOL)random {
	return mpd_status_get_random(self.status.data);
}

- (void)setShouldPlayRandom:(BOOL)mode {
	if (mode == self.random) {
		return;
	}
	BOOL completed = mpd_run_random(self.conn, mode);
	if (!completed) {
		NSLog(@"ERR. mpd_run_random");
		return;
	}
	self.status.data->random = mode;
}

- (NSUInteger)volume {
	return mpd_status_get_volume(self.status.data);
}

- (BOOL)setVolume:(NSUInteger)value {
	if (value == self.volume) {
		return YES;
	}
	BOOL completed = mpd_run_set_volume(self.conn, value);
	if (!completed) {
		NSLog(@"ERR. mpd_run_set_volume. mpd_error: %d.", mpd_connection_get_error(self.conn));
		return NO;
	}
	self.status.data->volume = value;
	return completed;
}

- (NSUInteger)kBitRate {
	return mpd_status_get_kbit_rate(self.status.data);
}

- (NSUInteger)seek {
	return mpd_status_get_elapsed_time(self.status.data);
}

- (void)seekTo:(NSUInteger)duration {
	if (!self.currentSong) {
		NSLog(@"WARN. No active currentSong.");
		return;
	}
	
	if (duration >= self.currentSong.data->duration) {
		return;
	}
	BOOL completed = mpd_run_seek_id(self.conn, self.currentSong.data->id, duration);
	if (!completed) {
		NSLog(@"ERR. mpd_run_seek_id");
		return;
	}
	
	self.status.data->elapsed_time = duration;
	self.status.data->elapsed_ms = duration * 1000;
	
	// MPD starts playing automatically on seek.
	self.status.state = PlayerStatePlaying;
}

- (int)queueVersion {
	return mpd_status_get_queue_version(self.status.data);
}

- (int)queueLength {
	return mpd_status_get_queue_length(self.status.data);
}

- (BOOL)isPlaying {
	return PlayerStatePlaying==self.status.state;
}

@end
