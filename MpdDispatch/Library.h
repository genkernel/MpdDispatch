//
//  Library.h
//  MpdDispatch
//
//  Created by kernel on 4/07/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "LibraryItems.h"

@class Directory;

@interface Library : NSObject
- (id)initWithDirectory:(Directory *)directory rootPath:(NSString *)path;
- (LibraryItems *)sortItemsWithTag:(SongTags)tag;
@end
