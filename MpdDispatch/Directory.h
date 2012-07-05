//
//  Directory.h
//  MpdDispatch
//
//  Created by kernel on 6/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "Helper.h"
#import "Song.h"
#import "Library.h"

@interface Directory : Helper
@property (strong, nonatomic, readonly) NSDictionary *directories;
@property (strong, nonatomic, readonly) NSDictionary *songs;
@property (strong, nonatomic, readonly) NSDictionary *playlists;

- (BOOL)rescan;
- (BOOL)rescanCheckingUnmodifiedFiles:(BOOL)force;
- (BOOL)loadAll;
- (Library *)loadRootLibrary;
- (Library *)loadLibraryForDirectoryPath:(NSString *)path;
@end
