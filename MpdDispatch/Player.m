//
//  Player.m
//  MpdDispatch
//
//  Created by kernel on 6/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "Player.h"
#import "Helper+Internals.h"
#import "Status+Internals.h"
#import "Song+Internals.h"

@interface Player()
- (Status *)loadStatus;
- (Song *)loadCurentSong;
- (NSArray *)loadQueue;
@property (assign, nonatomic, readonly) int queueVersion, queueLength;
@end

@implementation Player {
	NSUInteger lastUpdateQueueVersion;
}
@synthesize queue, status, currentSong, autoplay;
@dynamic volume, repeat, seek;
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
			Song *newSong = [[Song alloc] initWithSongData:song];
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
			Song *updatedSong = [[Song alloc] initWithSongData:song];
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

- (Song *)loadCurentSong {
	struct mpd_song *song = mpd_run_current_song(self.conn);
	if (!song) {
		// No current song playing.
		return nil;
	}
	return [[Song alloc] initWithSongData:song];
}

- (Status *)loadStatus {
	struct mpd_status *data = mpd_run_status(self.conn);
	if (!data) {
		NSLog(@"mpd_error: %d", mpd_connection_get_error(self.conn));
		return nil;
	}
	return [[Status alloc] initWithStatusData:data];
}

#pragma mark Instance methods

// update
// Requests curentSong, status and playing queue(if queue changed) update.
- (void)update {
	currentSong = [self loadCurentSong];
	status = [self loadStatus];
	
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
	return mpd_run_add(self.conn, [uri UTF8String]);
}

// loadAndPlayURI:
// Clears tracklist queue, appends new song and starts playback.
- (BOOL)loadAndPlayURI:(NSString *)uri {
	BOOL completed = mpd_run_clear(self.conn) && mpd_run_add(self.conn, [uri UTF8String]) && mpd_run_play(self.conn);
	
	enum mpd_error code = mpd_connection_get_error(self.conn);
	completed = MPD_ERROR_SUCCESS==code;
	if (!completed) {
		NSLog(@"mpd_error: %d", code);
	}
	return completed;
}

- (BOOL)playSong:(Song *)song {
	if (song.position >= self.queue.count) {
		return NO;
	}
	BOOL completed = mpd_run_play_pos(self.conn, song.position);
	if (completed) {
		currentSong = song;
		self.status.state = PlayerStatePlaying;
	}
	return completed;
}

#pragma mark Properties

- (BOOL)repeat {
	return mpd_status_get_repeat(self.status.data);
}

- (void)setRepeat:(BOOL)mode {
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

- (void)setRandom:(BOOL)mode {
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

- (void)setVolume:(NSUInteger)value {
	if (value == self.volume) {
		return;
	}
	BOOL completed = mpd_run_set_volume(self.conn, value);
	if (!completed) {
		NSLog(@"ERR. mpd_run_set_volume");
		return;
	}
	self.status.data->volume = value;
}

- (NSUInteger)seek {
	return mpd_status_get_elapsed_time(self.status.data);
}

- (void)setSeek:(NSUInteger)duration {
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
