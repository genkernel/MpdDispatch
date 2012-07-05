//
//  Library.h
//  MpdDispatch
//
//  Created by kernel on 4/07/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "Helper.h"

@interface Search : Helper
@property (strong, nonatomic, readonly) NSArray *artists;
- (BOOL)loadArtists;
@end
