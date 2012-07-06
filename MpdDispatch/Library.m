//
//  Library.m
//  MpdDispatch
//
//  Created by kernel on 4/07/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "Library.h"
#import "Directory.h"
#import "LibraryItems+Internals.h"

@interface Library()
@property (strong, nonatomic) NSMutableArray *loadingSongs, *loadingPlaylists;

- (void)parseDirectory:(Directory *)directory rootPath:(NSString *)path;
- (void)parseSong:(Song *)song;
- (void)parsePlaylist:(NSString *)playlist;
@end

@implementation Library
@synthesize loadingSongs, loadingPlaylists;

- (id)initWithDirectory:(Directory *)directory rootPath:(NSString *)path {
	self = [super init];
	if (self) {
		self.loadingSongs = [NSMutableArray array];
		self.loadingPlaylists = [NSMutableArray array];
		
		NSLog(@"0. Start Lib parsing: %@.", directory);
		[self parseDirectory:directory rootPath:path];
		NSLog(@"1. Finished LIb parsing: %@.", directory);
	}
	return self;
}

- (LibraryItems *)sortItemsWithTag:(SongTags)tag {
	LibraryItems *items = [[LibraryItems alloc] initWithSortingTag:tag];
	[items loadItems:self.loadingSongs];
	return items;
}

- (void)parseDirectory:(Directory *)directory rootPath:(NSString *)path {
	// Parse subdirectories.
	for (NSString *name in directory.directories[path]) {
		[self parseDirectory:directory rootPath:name];
	}
	
	// Parse playlists in this directory.
	for (NSString *playlist in directory.playlists[path]) {
		[self parsePlaylist:playlist];
	}
	
	// Parse songs in this directory.
	for (Song *song in directory.songs[path]) {
		[self parseSong:song];
	}
}

- (void)parseSong:(Song *)song {
	[self.loadingSongs addObject:song];
}

- (void)parsePlaylist:(NSString *)playlist {
	[self.loadingPlaylists addObject:playlist];
}

@end
