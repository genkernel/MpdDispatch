//
//  Entity.m
//  MpdDispatch
//
//  Created by kernel on 8/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "MDHelper.h"
#import "MDHelper+Internals.h"

@implementation MDHelper
@synthesize conn;

- (void)didConnect {
	// Dummy.
}

- (void)didAuthenticate {
	// Dummy.
}

- (void)didDisconnect {
	self.conn = NULL;
}

@end
