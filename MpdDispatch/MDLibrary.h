//
//  Library.h
//  MpdDispatch
//
//  Created by kernel on 4/07/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "MDLibraryItems.h"

@class MDDirectory;

@interface MDLibrary : NSObject
- (id)initWithDirectory:(MDDirectory *)directory rootPath:(NSString *)path;
- (MDLibraryItems *)sortItemsWithTag:(SongTags)tag;
@end
