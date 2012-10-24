//
//  Directory.m
//  MpdDispatch
//
//  Created by kernel on 6/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "MDDirectory.h"
#import "MDHelper+Internals.h"

static NSString *rootDirectoryPath = @"";

@interface MDDirectory() {
	BOOL isLoaded;
}
@property (strong, nonatomic, readwrite) NSMutableDictionary *directories;
@property (strong, nonatomic, readwrite) NSMutableDictionary *songs;
@property (strong, nonatomic, readwrite) NSMutableDictionary *playlists;

@property (strong, nonatomic) MDLibrary *rootLibrary;

- (BOOL)parseDirectory:(NSString *)path;
@end

@implementation MDDirectory
@synthesize directories, songs, playlists, rootLibrary;

- (BOOL)rescan {
	return [self rescanCheckingUnmodifiedFiles:NO];
}

- (BOOL)rescanCheckingUnmodifiedFiles:(BOOL)force {
	unsigned int jobId = 0;
	if (force) {
		jobId = mpd_run_rescan(self.conn, NULL);
	} else {
		jobId = mpd_run_update(self.conn, NULL);
	}
	return 0 < jobId;
}

- (void)setConn:(struct mpd_connection *)newConn {
	if (newConn == self.conn) {
		return;
	}
	[super setConn:newConn];
	
	isLoaded = NO;
}

- (BOOL)loadAll {
	if (isLoaded) {
		return YES;
	}
	
	self.directories = [NSMutableDictionary new];
	self.songs = [NSMutableDictionary new];
	self.playlists = [NSMutableDictionary new];
	
	NSLog(@"0. loadAll - Start.");
	isLoaded = [self parseDirectory:rootDirectoryPath];
	NSLog(@"1. loadAll - Done.");
	return isLoaded;
}

- (BOOL)parseDirectory:(NSString *)parentDirectory {
	bool completed = mpd_send_list_meta(self.conn, [parentDirectory UTF8String]);
	//bool completed = mpd_send_list_all_meta(self.conn, [parentDirectory UTF8String]);
	if (!completed) {
		return NO;
	}
	
	NSMutableArray *foundDirectories = [NSMutableArray array];
	NSMutableArray *foundSongs = [NSMutableArray array];
	NSMutableArray *foundPlaylists = [NSMutableArray array];
	
	struct mpd_entity * entity = NULL;
	while ((entity = mpd_recv_entity(self.conn))) {
		switch (mpd_entity_get_type(entity)) {
			case MPD_ENTITY_TYPE_UNKNOWN:
				NSLog(@"WARN. Unknown entity.");
				break;
			case MPD_ENTITY_TYPE_SONG: {
				const struct mpd_song *pureSong = mpd_entity_get_song(entity);
				const struct mpd_song *song = mpd_song_dup(pureSong);
				MDSong *newSong = [[MDSong alloc] initWithSongData:(struct mpd_song *)song];
				[foundSongs addObject:newSong];
			}
				break;
			case MPD_ENTITY_TYPE_DIRECTORY: {
				// mpd_directory_dup();
				const struct mpd_directory *directory = mpd_entity_get_directory(entity);
				NSString *directoryName = [NSString stringWithUTF8String:mpd_directory_get_path(directory)];
				if ([directoryName isEqualToString:parentDirectory]) {
					NSLog(@"directoryName equals - Tham mai?");
					break;
				}
				[foundDirectories addObject:directoryName];
			}
				break;
			case MPD_ENTITY_TYPE_PLAYLIST: {
				//mpd_playlist_dup();
				const struct mpd_playlist *playlist = mpd_entity_get_playlist(entity);
				NSString *playlistPath = [NSString stringWithUTF8String:mpd_playlist_get_path(playlist)];
				[foundPlaylists addObject:playlistPath];
			}
				break;
		}
		mpd_entity_free(entity);
	}
	mpd_response_finish(self.conn);
	
	if (foundDirectories.count > 0) {
		[self.directories setValue:foundDirectories forKey:parentDirectory];
	}
	if (foundSongs.count > 0) {
		if (self.songs[parentDirectory]) {
			NSLog(@"WHY directory key exists?");
		}
		[self.songs setValue:foundSongs forKey:parentDirectory];
	}
	if (foundPlaylists.count > 0) {
		[self.playlists setValue:foundPlaylists forKey:parentDirectory];
	}
	
	for (NSString *directory in foundDirectories) {
		BOOL completed = [self parseDirectory:directory];
		if (!completed) {
			NSLog(@"ERR. %d: %@", completed, directory);
		}
	}
	
	BOOL connected = MPD_ERROR_SUCCESS==mpd_connection_get_error(self.conn);
	return connected;
}

- (MDLibrary *)loadRootLibrary {
	if (rootLibrary) {
		return rootLibrary;
	}
	rootLibrary = [[MDLibrary alloc] initWithDirectory:self rootPath:rootDirectoryPath];
	return rootLibrary;
}

- (MDLibrary *)loadLibraryForDirectoryPath:(NSString *)path {
	return [[MDLibrary alloc] initWithDirectory:self rootPath:path];
}

@end
