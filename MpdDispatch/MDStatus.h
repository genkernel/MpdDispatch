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

@interface MDStatus : NSObject
- (id)initWithStatusData:(struct mpd_status *)status;
@property (assign, nonatomic, readonly)PlayerState state;
@end
