//
//  Player.m
//  MpdDispatch
//
//  Created by kernel on 6/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "Player.h"
#import "Helper+Internals.h"

@interface Player()
@property (strong, nonatomic, readwrite) NSArray *queue;
@end

@implementation Player
@synthesize queue;

- (void)didAuthenticate {
	[super didAuthenticate];
	
	
	// TODO: queueLength
	BOOL completed = mpd_send_list_queue_meta(self.conn);
	if (!completed) {
		NSLog(@"ERR. mpd_send_list_queue_meta");
		return;
	}
	
	NSMutableArray *items = [NSMutableArray array];
	struct mpd_song *song = NULL;
	while ((song = mpd_recv_song(self.conn))) {
		Song *newSong = [[Song alloc] initWithSongData:song];
		[items addObject:newSong];
	}
	self.queue = [NSArray arrayWithArray:items];
	
	completed = mpd_response_finish(self.conn);
	if (!completed) {
		NSLog(@"ERR. mpd_response_finish");
		return;
	}
}

- (BOOL)stop {
	return mpd_run_stop(self.conn);
}

- (BOOL)play {
	return mpd_run_play(self.conn);
}

- (BOOL)pause {
	return mpd_run_pause(self.conn, true);
}

- (BOOL)toggle {
	return mpd_run_toggle_pause(self.conn);
}

- (BOOL)next {
	return mpd_run_next(self.conn);
}

- (BOOL)prev {
	return mpd_run_previous(self.conn);
}

- (Song *)currentSong {
	struct mpd_song *song = mpd_run_current_song(self.conn);
	if (!song) {
		// No current song playing.
		return nil;
	}
	return [[Song alloc] initWithSongData:song];
}

- (Status *)status {
	struct mpd_status *status = mpd_run_status(self.conn);
	if (!status) {
		NSLog(@"mpd_error: %d", mpd_connection_get_error(self.conn));
		return nil;
	}
	return [[Status alloc] initWithStatusData:status];
}

- (BOOL)addURI:(NSString *)uri {
	return mpd_run_add(self.conn, [uri UTF8String]);
}

- (BOOL)loadAndPlayURI:(NSString *)uri {
	mpd_run_clear(self.conn);
	mpd_run_add(self.conn, [uri UTF8String]);
	mpd_run_play(self.conn);
	
	enum mpd_error code = mpd_connection_get_error(self.conn);
	BOOL completed = MPD_ERROR_SUCCESS==code;
	if (!completed) {
		NSLog(@"mpd_error: %d", code);
	}
	return completed;
}

@end
