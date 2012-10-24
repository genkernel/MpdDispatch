//
//  Library.m
//  MpdDispatch
//
//  Created by kernel on 4/07/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "MDSearch.h"
#import "MDHelper+Internals.h"

@interface MDSearch()
@property (strong, nonatomic, readwrite) NSArray *artists;

- (BOOL)prepareStats;
@end

@implementation MDSearch {
	struct mpd_stats *stats;
}
@synthesize artists;

- (void)dealloc {
	if (stats) {
		mpd_stats_free(stats);
	}
}

- (BOOL)prepareStats {
	if (stats) {
		return YES;
	}
	//BOOL completed = mpd_count_db_songs(self.conn) && mpd_search_commit(self.conn);
	BOOL completed = YES;
	if (completed) {
		stats = mpd_run_stats(self.conn);
		//stats = mpd_recv_stats(self.conn);
	}
	completed = NULL != stats;
	//completed = MPD_ERROR_SUCCESS==mpd_connection_get_error(self.conn) && mpd_response_finish(self.conn);
	return completed;
}

- (BOOL)loadArtists {
	BOOL completed = [self prepareStats];
	if (!completed) {
		return NO;
	}
	
	completed = mpd_search_db_tags(self.conn, MPD_TAG_ARTIST) && mpd_search_commit(self.conn);
	if (!completed) {
		return NO;
	}
	
	NSUInteger count = stats->number_of_artists;
	NSMutableArray *items = [NSMutableArray arrayWithCapacity:count];
	
	struct mpd_pair *pair = NULL;
	while ((pair = mpd_recv_pair_tag(self.conn,MPD_TAG_ARTIST)) != NULL) {
		NSString *title = [NSString stringWithUTF8String:pair->value];
		[items addObject:title];
		
		mpd_return_pair(self.conn, pair);
	}
	self.artists = [NSArray arrayWithArray:items];
	
	completed = MPD_ERROR_SUCCESS==mpd_connection_get_error(self.conn) && mpd_response_finish(self.conn);
	return completed;
}

@end
