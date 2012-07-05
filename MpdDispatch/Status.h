//
//  Status.h
//  MpdDispatch
//
//  Created by kernel on 8/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	PlayerStateUnknown,
	PlayerStateStopped,
	PlayerStatePlaying,
	PlayerStatePaused
} PlayerState;

@interface Status : NSObject
- (id)initWithStatusData:(struct mpd_status *)status;
- (PlayerState)state;

@property (assign, nonatomic, readonly) int volume, queueVersion, queueLength;
@property (assign, nonatomic, readonly) BOOL repeat, random;
@end
