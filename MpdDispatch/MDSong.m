//
//  Song.m
//  MpdDispatch
//
//  Created by kernel on 8/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "MDSong.h"
#import "MDSong+Internals.h"

@implementation MDSong {
	NSString *tags[MPD_TAG_COUNT];
}
@synthesize data;
@synthesize uri, title, duration;
@dynamic durationSecs, position, uid;

- (id)initWithSongData:(struct mpd_song *)origin {
	self = [self init];
	if (self) {
		data = origin;
		
		// Parse * tags.
		for (int tag=0; tag<MPD_TAG_COUNT; tag++) {
			const char *value;
			//while ((value = mpd_song_get_tag(song, type, 0)) != NULL) {
			if ((value = mpd_song_get_tag(data, tag, 0)) != NULL) {
				tags[tag] = [NSString stringWithUTF8String:value];
			}
		}
		
		// Parse uri.
		const char *uriValue = mpd_song_get_uri(data);
		if (uriValue) {
			uri = [NSString stringWithUTF8String:uriValue];
		}
		
		// Parse title.
		title = [self tagValueOfType:MPD_TAG_TITLE];
		if (!title) {
			title = [[self.uri lastPathComponent] stringByDeletingPathExtension];
		}
		
		unsigned total = mpd_song_get_duration(data);
		duration = [[self class] durationWithSeconds:total];
	}
	return self;
}

- (void)dealloc {
	if (data) {
		mpd_song_free(data);
	}
	
	for (int tag=0; tag<MPD_TAG_COUNT; tag++) {
		tags[tag] = nil;
	}
}

- (NSString *)description {
	return [NSString stringWithFormat:@"[%@ 0x%x] (%d) %@", NSStringFromClass([self class]), (int)self, self.position, self.title];
}

- (NSString *)tagValueOfType:(SongTags)tag {
	return tags[tag];
}

// durationWithSeconds:
// Represents seconds amount in format: HH:MM:SS.
+ (NSString *)durationWithSeconds:(NSUInteger)total {
	unsigned hrs = total / 3600;
	unsigned mins = (total % 3600) / 60;
	unsigned secs = (total % 3600) % 60;
	
	NSString * (^twoDigits)(unsigned value) = ^(unsigned value) {
		NSString *format = value>9 ? @"%d" : @"0%d";
		return [NSString stringWithFormat:format, value];
	};
	NSString *duration = [NSString stringWithFormat:@"%@:%@:%@", twoDigits(hrs), twoDigits(mins), twoDigits(secs)];
	return duration;
}

#pragma mark Properties

- (NSUInteger)durationSecs {
	return mpd_song_get_duration(data);
}

- (NSUInteger)position {
	return mpd_song_get_pos(data);
}

- (NSUInteger)uid {
	return mpd_song_get_id(data);
}

@end
