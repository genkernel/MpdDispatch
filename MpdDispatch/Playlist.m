//
//  Playlist.m
//  MpdDispatch
//
//  Created by kernel on 8/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "Playlist.h"
#import "Helper+Internals.h"

@implementation Playlist

- (NSArray *)list {
	bool completed = mpd_send_list_playlists(self.conn);
	if (!completed) {
		NSLog(@"mpd_error: %d", mpd_connection_get_error(self.conn));
		return nil;
	}
	
	NSMutableArray *items = [NSMutableArray array];
	
	struct mpd_playlist *playlist = NULL;
	while ((playlist = mpd_recv_playlist(self.conn))) {
		const char *path = mpd_playlist_get_path(playlist);
		[items addObject:[NSString stringWithUTF8String:path]];
		
		mpd_playlist_free(playlist);
	}
	mpd_response_finish(self.conn);
	
	BOOL connected = MPD_ERROR_SUCCESS==mpd_connection_get_error(self.conn);
	if (!connected) {
		return nil;
	}
	return items;
}

@end
