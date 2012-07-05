//
//  Song.m
//  MpdDispatch
//
//  Created by kernel on 8/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "Song.h"

@implementation Song {
	struct mpd_song *song;
	NSString *tags[MPD_TAG_COUNT];
}
@synthesize uri, title, duration;

- (id)initWithSongData:(struct mpd_song *)origin {
	self = [self init];
	if (self) {
		song = origin;
		
		// Parse * tags.
		for (int tag=0; tag<MPD_TAG_COUNT; tag++) {
			const char *value;
			//while ((value = mpd_song_get_tag(song, type, 0)) != NULL) {
			if ((value = mpd_song_get_tag(song, tag, 0)) != NULL) {
				tags[tag] = [NSString stringWithUTF8String:value];
			}
		}
		
		// Parse uri.
		const char *uriValue = mpd_song_get_uri(song);
		if (uriValue) {
			uri = [NSString stringWithUTF8String:uriValue];
		}
		
		// Parse title.
		title = [self tagValueOfType:MPD_TAG_TITLE];
		if (!title) {
			title = [self.uri lastPathComponent];
		}
		
		// Parse duration: HH:MM:SS
		unsigned total = mpd_song_get_duration(song);
		unsigned hrs = total / 3600;
		unsigned mins = (total % 3600) / 60;
		unsigned secs = (total % 3600) % 60;
		
		NSString * (^twoDigits)(unsigned value) = ^(unsigned value) {
			NSString *format = value>9 ? @"%d" : @"0%d";
			return [NSString stringWithFormat:format, value];
		};
		duration = [NSString stringWithFormat:@"%@:%@:%@", twoDigits(hrs), twoDigits(mins), twoDigits(secs)];
	}
	return self;
}

- (void)dealloc {
	mpd_song_free(song);
	
	for (int tag=0; tag<MPD_TAG_COUNT; tag++) {
		tags[tag] = nil;
	}
}

- (NSString *)tagValueOfType:(SongTags)tag {
	return tags[tag];
}

@end