//
//  Playlist.m
//  MpdDispatch
//
//  Created by kernel on 11/07/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "MDPlaylist.h"

@interface MDPlaylist()
@property (strong, nonatomic, readwrite) NSString *pathName;
@property (strong, nonatomic, readwrite) NSDate *lastModified;
@end

@implementation MDPlaylist {
	struct mpd_playlist *data;
}
@synthesize pathName, lastModified;

- (id)initWithPlaylistData:(struct mpd_playlist *)playlist {
	self = [self init];
	if (self) {
		data = playlist;
		
		// pathName.
		self.pathName = [NSString stringWithUTF8String:mpd_playlist_get_path(data)];
		// lastModified.
		time_t time = mpd_playlist_get_last_modified(data);
		self.lastModified =[NSDate dateWithTimeIntervalSince1970:time];
	}
	return self;
}

- (void)dealloc {
	mpd_playlist_free(data);
}

@end
