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
//@property (strong, nonatomic) NSMutableDictionary *loadingArtists, *loadingAlbums, *loadingGenres, *loadingComposers;
@property (strong, nonatomic) NSMutableArray *loadingSongs, *loadingPlaylists;

- (void)parseDirectory:(Directory *)directory rootPath:(NSString *)path;
- (void)parseSong:(Song *)song;
- (void)parsePlaylist:(NSString *)playlist;
@end

@implementation Library {
	//NSMutableDictionary *tagParsers[MPD_TAG_COUNT];
}
@synthesize artists, albums, genres, composers;
//@synthesize songs, playlists;
//@synthesize loadingArtists, loadingAlbums, loadingGenres, loadingComposers;
@synthesize loadingSongs, loadingPlaylists;

- (id)initWithDirectory:(Directory *)directory rootPath:(NSString *)path {
	self = [super init];
	if (self) {
		self.loadingSongs = [NSMutableArray array];
		self.loadingPlaylists = [NSMutableArray array];
		
		NSLog(@"0. Start Lib parsing.");
		[self parseDirectory:directory rootPath:path];
		NSLog(@"1. Finished LIb parsing.");
		
		artists = [[LibraryItems alloc] initWithSortingTag:SongTagArtist];
		[artists loadItems:loadingSongs];
		albums = [[LibraryItems alloc] initWithSortingTag:SongTagAlbum];
		[albums loadItems:loadingSongs];
		composers = [[LibraryItems alloc] initWithSortingTag:SongTagComposer];
		[composers loadItems:loadingSongs];
		genres = [[LibraryItems alloc] initWithSortingTag:SongTagGenre];
		[genres loadItems:loadingSongs];
		
		//songs = [NSArray arrayWithArray:self.loadingSongs];
		//playlists = [NSArray arrayWithArray:self.loadingPlaylists];
	}
	return self;
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
	/*
	for (int tag=0; tag<MPD_TAG_COUNT; tag++) {
		NSMutableDictionary *d = tagParsers[tag];
		if (!d) {
			continue;
		}
		
		NSString *val = [song tagValueOfType:tag];
		if (!val) {
			continue;
		}
		
		NSMutableArray *items = d[val];
		if (items) {
			[items addObject:song];
		} else {
			items = [NSMutableArray arrayWithObject:song];
		}
		d[val] = items;
	}*/
}

- (void)parsePlaylist:(NSString *)playlist {
	[self.loadingPlaylists addObject:playlist];
}

@end
