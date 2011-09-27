//
//  Path.mm
//
//  Created by Aaron Pendley on 7/26/10.
//  Copyright 2010 Aaron Pendley. All rights reserved.
//

#import "Path.h"
#import "CGPointExtension.h"

@implementation Path

-(float)length
{
	if( lengthDirty )
	{
		length = 0;
		
		int size = points.count;
		for( int i = 1; i < size; ++i )
		{
			CGPoint cur = [points->data->arr[i] CGPointValue];
			CGPoint prev = [points->data->arr[i - 1] CGPointValue];
			
			length += ccpLength(ccpSub(cur, prev));
		}
		
		lengthDirty = false;
	}
	
	return length;
}

-(int)pointCount
{
	return points.count;
}

-(id)initWithCapacity:(unsigned int)capacity
{
	if( ![super init] )
		return nil;
	
	points = [[CCArray alloc] initWithCapacity:capacity];
	
	return self;
}

-(void)dealloc
{
	[points release];
	[super dealloc];
}

-(CGPoint)pointAtIndex:(int)index
{
	return [[points objectAtIndex:index] CGPointValue];
}

-(void)addPoint:(CGPoint)point
{
	[points addObject:[NSValue valueWithCGPoint:point]];
	lengthDirty = YES;
}

@end
