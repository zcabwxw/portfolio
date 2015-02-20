//
//  VideoNode.h
//  healthy-moments
//
//  Created by Katz, Nevin on 9/11/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoNode : NSObject
{
    NSString* path;
    
    NSString* title;
    
    NSString* description;
    
    NSString* thumbnail;
}

@property NSString* path;

@property NSString* title;

@property NSString* description;

@property NSString* thumbnail;

@end
