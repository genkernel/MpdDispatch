//
//  Directory.h
//  MpdDispatch
//
//  Created by kernel on 6/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "MDHelper.h"
#import "MDSong.h"
#import "MDLibrary.h"

@interface MDDirectory : MDHelper
@property (strong, nonatomic, readonly) NSDictionary *directories;
@property (strong, nonatomic, readonly) NSDictionary *songs;
@property (strong, nonatomic, readonly) NSDictionary *playlists;

- (BOOL)rescan;
- (BOOL)rescanCheckingUnmodifiedFiles:(BOOL)force;
- (BOOL)loadAll;
- (MDLibrary *)loadRootLibrary;
- (MDLibrary *)loadLibraryForDirectoryPath:(NSString *)path;
@end
