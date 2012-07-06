//
//  Status+Internals.h
//  MpdDispatch
//
//  Created by kernel on 6/07/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#ifndef MpdDispatch_Status_Internals_h
#define MpdDispatch_Status_Internals_h

@interface Status()
@property (assign, nonatomic, readonly) struct mpd_status *data;
@property (assign, nonatomic, readwrite)PlayerState state;
@end

#endif
