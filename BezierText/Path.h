//
//  Path.h
//
//  Created by Aaron Pendley on 7/26/10.
//  Copyright 2010 Aaron Pendley. All rights reserved.
//

#import "CCArray.h"

@interface Path : NSObject
{
	CCArray* points;
	float length;
	BOOL lengthDirty;
}

@property(nonatomic, readonly) int pointCount;
@property(nonatomic, readonly) float length;

-(id)initWithCapacity:(unsigned int)capacity;

-(void)addPoint:(CGPoint)point;

-(CGPoint)pointAtIndex:(int)index;

@end
