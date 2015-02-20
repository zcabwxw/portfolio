//
//  Tile.m
//  DynamicViews
//
//  Created by nkatz on 3/20/13.
//  Copyright (c) 2013 nkatz. All rights reserved.
//

#import "Tile.h"

@implementation Tile

@synthesize myType;

@synthesize trueType;

@synthesize myLoc;

@synthesize clicked;

@synthesize tooClose;

@synthesize changed;

@synthesize isHint;

@synthesize hintImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
