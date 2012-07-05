//
//  Library.h
//  MpdDispatch
//
//  Created by kernel on 4/07/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "LibraryItems.h"

@class Directory;

@interface Library : NSObject
- (id)initWithDirectory:(Directory *)directory rootPath:(NSString *)path;

@property (strong, nonatomic, readonly) LibraryItems *artists, *albums, *genres, *composers;

//@property (strong, nonatomic, readonly) NSDictionary *artists, *albums, *genres, *composers;
//@property (strong, nonatomic, readonly) NSArray *songs, *playlists;

//@property (strong, nonatomic, readonly) NSArray *artistsSectionIndexTitles, *albumsSectionIndexTitles, *genresSectionIndexTitles, *composersSectionIndexTitles;
//@property (strong, nonatomic, readonly) NSArray *songsSectionIndexTitles, *playlistsSectionIndexTitles;
@end
