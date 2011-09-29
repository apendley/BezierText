//
//  BezierText.m
//  BezierText
//
//  Created by Aaron Pendley on 9/29/11.
//  Copyright 2011 CosMind & Blue. All rights reserved.
//

#import "PathText.h"

static inline BOOL floatEqual(float n1, float n2)
{
	return fabs(n1 - n2) < FLT_EPSILON;	
}

@implementation PathText

@synthesize opacity = opacity_, color = color_;

-(void)initCharactersWithString:(NSString*)string fntFile:(NSString*)fntFile direction:(EPathTextDirection)direction
{
	// using CCLabelBMFont to do the heavy lifting of generating and spacing out the letters.
	// then we'll use the same texture atlas and kidnap it's children.
	
	CCLabelBMFont* label = [[CCLabelBMFont alloc] initWithString:string fntFile:fntFile];
	self.textureAtlas = label.textureAtlas;
	
	if( direction == ePTD_Forward )
	{
		// ugh..using convenienve method because init method causes an NSArray conflict warning
		CCArray* tempArray = [CCArray arrayWithArray:label.children];
		
		CCSprite* child;
		CCARRAY_FOREACH(tempArray, child)
		{
			[label removeChild:child cleanup:NO];
			[self addChild:child];
		}
		
		[tempArray removeAllObjects];
	}
	else
	{	
		for( int i = label.children.count - 1; i >= 0; --i )
		{
			CCSprite* child = [label.children objectAtIndex:i];
			
			[child retain];
			[label removeChild:child cleanup:NO];
			[self addChild:child];
			[child release];
		}
	}
	
	
	[label release];
}

+(id)pathTextWithString:(NSString*)string fntFile:(NSString*)fntFile path:(Path*)path direction:(EPathTextDirection)direction speed:(float)speed
{
	return [[[self alloc] initWithString:string fntFile:fntFile path:path direction:direction speed:speed] autorelease];
}

-(id) initWithString:(NSString*)string fntFile:(NSString*)fntFile path:(Path*)path_ direction:(EPathTextDirection)direction speed:(float)speed_ 
{
	if( ![super initWithFile:fntFile capacity:[string length]] )
		return nil;
	
	opacity_ = 255;
	color_ = ccWHITE;
	
	opacityModifyRGB_ = [[textureAtlas_ texture] hasPremultipliedAlpha];
	
	speed = speed_;
	path = [path_ retain];	
	
	[self initCharactersWithString:string fntFile:fntFile direction:direction];
	
	int letterCount = self.children.count;
	
	// get the initial spacing
	NSMutableArray* originalDistances = [[NSMutableArray alloc] initWithCapacity:letterCount];
	[originalDistances addObject:[NSNumber numberWithFloat:0.0f]];
	
	for( int c = 1; c < letterCount; ++c )
	{
		CCNode* child = [self.children objectAtIndex:c];
		CCNode* prevChild = [self.children objectAtIndex:c-1];
		[originalDistances addObject:[NSNumber numberWithFloat:ccpDistance(prevChild.position, child.position)]];
	}	
	
	pathData = malloc(sizeof(SSpritePathData) * letterCount);	
	
	// initialize the path following data for all of the children
	float endPosition = path.length;	
	for( int c = 0; c < letterCount; ++c )
	{
		CCNode* child = [self.children objectAtIndex:c];		
		float originalDist = [[originalDistances objectAtIndex:c] floatValue];
		
		endPosition -= originalDist;
		
		child.position = [path pointAtIndex:0];
		child.visible = NO;
		
		pathData[c].position = 0;
		pathData[c].endPosition = endPosition;
		pathData[c].pathIndex = 0;
		pathData[c].pathIndexPosition = 0;
		pathData[c].maxDistToNext = originalDist;
	}
	
	[originalDistances release];
	
	[self scheduleUpdate];
	
	return self;
}

-(void)update:(ccTime)dt
{	
	for( int c = 0; c < self.children.count; ++c )
	{	
		CCNode* child = [self.children objectAtIndex:c];
		SSpritePathData* bd = &pathData[c];
		
		float pathPos = bd->position;
		
		if( c > 0 )
		{
			SSpritePathData* pbd = &pathData[c-1];
			
			float dist = pbd->position - bd->position;
			
			if( dist > bd->maxDistToNext )
				pathPos += (dist - bd->maxDistToNext);
		}
		else
		{
			pathPos += speed * dt;
		}
		
		if( pathPos > 0 )
			child.visible = YES;
		
		pathPos = MIN(pathPos, bd->endPosition);
		
		CGPoint dest = child.position;
		
		if( pathPos > bd->position )
		{
			CGPoint curPoint = [path pointAtIndex:bd->pathIndex];
			CGPoint nextPoint =[path pointAtIndex:bd->pathIndex+1];
			float distToNext = ccpLength(ccpSub(nextPoint, curPoint));
			float nextPointPos = bd->pathIndexPosition + ccpLength(ccpSub(nextPoint, curPoint));
			
			BOOL firstLoop = YES;
			while( nextPointPos <= pathPos )
			{
				if( bd->pathIndex == path.pointCount - 1 )
				{
					bd->pathIndex = path.pointCount - 1;
					bd->pathIndexPosition = path.length;
					curPoint = [path pointAtIndex:bd->pathIndex];
					nextPoint = curPoint;
					break;						
				}					
				else
				{
					if( !firstLoop )
					{
						curPoint = [path pointAtIndex:bd->pathIndex];
						nextPoint = [path pointAtIndex:bd->pathIndex+1];
						distToNext = ccpLength(ccpSub(nextPoint, curPoint));
						nextPointPos += distToNext;
					}
					else
						firstLoop = NO;
					
					if( nextPointPos <= pathPos )
					{
						bd->pathIndex++;
						bd->pathIndexPosition = nextPointPos;
					}
				}
			}
			
			bd->position = pathPos;						
			float distFromCurPoint = fabsf(bd->position - bd->pathIndexPosition);
			
			if( floatEqual(nextPoint.x, curPoint.x) && floatEqual(nextPoint.y, curPoint.y) )
			{
				dest = nextPoint;
			}
			else
			{
				CGPoint dir = ccpNormalize(ccpSub(nextPoint, curPoint));
				dir = ccpMult(dir, distFromCurPoint);
				dest = ccpAdd(curPoint, dir);
			}
		}
		
		if( !ccpFuzzyEqual(dest, child.position, FLT_EPSILON) )
		{
			child.rotation = CC_RADIANS_TO_DEGREES(ccpToAngle(ccpSub(child.position, dest))) * -1;
		}
		
		child.position = dest;
	}
	
	if( floatEqual(pathData[0].position, pathData[0].endPosition) )
	{
		[self unscheduleUpdate];
		
		free(pathData);
		pathData = NULL;
		
		[path release];
		path = nil;
	}
}

-(void)dealloc
{
	free(pathData);
	[path release];
	[super dealloc];
}

#pragma mark PathText - CCRGBAProtocol protocol

-(void) setColor:(ccColor3B)color
{
	color_ = color;
	
	CCSprite *child;
	CCARRAY_FOREACH(children_, child)
	[child setColor:color_];
}

-(void) setOpacity:(GLubyte)opacity
{
	opacity_ = opacity;
	
	id<CCRGBAProtocol> child;
	CCARRAY_FOREACH(children_, child)
	[child setOpacity:opacity_];
}
-(void) setOpacityModifyRGB:(BOOL)modify
{
	opacityModifyRGB_ = modify;
	
	id<CCRGBAProtocol> child;
	CCARRAY_FOREACH(children_, child)
	[child setOpacityModifyRGB:modify];
}

-(BOOL) doesOpacityModifyRGB
{
	return opacityModifyRGB_;
}


@end
