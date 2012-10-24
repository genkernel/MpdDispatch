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

@interface MDSong : NSObject
- (id)initWithSongData:(struct mpd_song *)song;
- (NSString *)tagValueOfType:(SongTags)type;
+ (NSString *)durationWithSeconds:(NSUInteger)value;

@property (strong, nonatomic, readonly) NSString *uri, *title, *duration;
@property (assign, nonatomic, readonly) NSUInteger durationSecs, position, uid;
@end
