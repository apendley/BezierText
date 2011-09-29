//
//  Path.mm
//
//  Created by Aaron Pendley on 7/26/10.
//  Copyright 2010 Aaron Pendley. All rights reserved.
//

#import "Path.h"
#import "CGPointExtension.h"

static inline float bezierat( float a, float b, float c, float d, float t )
{
	return (powf(1-t,3) * a + 
			3*t*(powf(1-t,2))*b + 
			3*powf(t,2)*(1-t)*c +
			powf(t,3)*d );
}


@implementation Path

+(id)pathWithCapacity:(unsigned int)capacity
{
	return [[[self alloc] initWithCapacity:capacity] autorelease];
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

-(unsigned int)pointCount
{
	return points.count;
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

-(void)addPointsWithBezier:(CGPoint[4])controlPoints pointCount:(unsigned int)pointCount
{
	for( int s = 0; s < pointCount; ++s )
	{
		float t = (float)s / pointCount;
		
		CGPoint p;
		p.x = bezierat(controlPoints[0].x, controlPoints[1].x, controlPoints[2].x, controlPoints[3].x, t);
		p.y = bezierat(controlPoints[0].y, controlPoints[1].y, controlPoints[2].y, controlPoints[3].y, t);
		[self addPoint:p];
	}
}


@end
