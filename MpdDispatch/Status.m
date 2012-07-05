//
//  Status.m
//  MpdDispatch
//
//  Created by kernel on 8/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "Status.h"

@implementation Status {
	struct mpd_status *status;
}
@dynamic volume, repeat;

- (id)initWithStatusData:(struct mpd_status *)origin {
	self = [self init];
	if (self) {
		status = origin;
	}
	return self;
}

- (void)dealloc {
	mpd_status_free(status);
}

- (PlayerState)state {
	return mpd_status_get_state(status);
}

#pragma mark Properties

- (int)volume {
	return mpd_status_get_volume(status);
}

- (int)queueVersion {
	return mpd_status_get_queue_version(status);
}

- (int)queueLength {
	return mpd_status_get_queue_length(status);
}

- (BOOL)repeat {
	return mpd_status_get_repeat(status);
}

- (BOOL)random {
	return mpd_status_get_random(status);
}

@end
