//
//  Status.m
//  MpdDispatch
//
//  Created by kernel on 8/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "Status.h"
#import "Status+Internals.h"

@implementation Status
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
	mpd_status_free(data);
}

@end
