//
//  Song+Internals.h
//  MpdDispatch
//
//  Created by kernel on 6/07/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#ifndef MpdDispatch_Song_Internals_h
#define MpdDispatch_Song_Internals_h

@interface MDSong()
@property (assign, nonatomic, readonly) struct mpd_song *data;
@end

#endif
