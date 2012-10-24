//
//  Status.m
//  MpdDispatch
//
//  Created by kernel on 8/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "MDStatus.h"
#import "MDStatus+Internals.h"

@implementation MDStatus
@synthesize data, state;

- (id)initWithStatusData:(struct mpd_status *)origin {
	self = [self init];
	if (self) {
		data = origin;
		
		state = mpd_status_get_state(data);
	}
	return self;
}

- (void)dealloc {
	if (data) {
		mpd_status_free(data);
	}
}

@end
