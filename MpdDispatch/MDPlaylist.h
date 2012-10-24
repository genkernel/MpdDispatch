//
//  Playlist.h
//  MpdDispatch
//
//  Created by kernel on 11/07/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDPlaylist : NSObject
- (id)initWithPlaylistData:(struct mpd_playlist *)playlist;
@property (strong, nonatomic, readonly) NSString *pathName;
@property (strong, nonatomic, readonly) NSDate *lastModified;
@end
