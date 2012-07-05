//
//  Song.h
//  MpdDispatch
//
//  Created by kernel on 8/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	SongTagArtist,
	SongTagAlbum,
	SongTagGenre = 6,
	SongTagComposer = 8,
	SongTagsCount
} SongTags;

@interface Song : NSObject
- (id)initWithSongData:(struct mpd_song *)song;
@property (strong, nonatomic, readonly) NSString *uri, *title, *duration;
- (NSString *)tagValueOfType:(SongTags)type;
@end
