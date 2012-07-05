//
//  Playlist+Internals.h
//  MpdDispatch
//
//  Created by kernel on 8/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#ifndef MpdDispatch_Playlist_Internals_h
#define MpdDispatch_Playlist_Internals_h

@interface Helper()
@property (assign, nonatomic) struct mpd_connection *conn;
- (void)didConnect;
- (void)didAuthenticate;
@end

#endif
