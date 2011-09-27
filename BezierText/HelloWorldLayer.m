//
//  HelloWorldLayer.m
//  BezierText
//
//  Created by Aaron Pendley on 9/26/11.
//  Copyright CosMind & Blue 2011. All rights reserved.
//




// Import the interfaces
#import "HelloWorldLayer.h"

static int const kBezierSamples = 100;
static float const kSpeed = 60.0f;

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

static inline float bezierat( float a, float b, float c, float d, ccTime t )
{
	return (powf(1-t,3) * a + 
			3*t*(powf(1-t,2))*b + 
			3*powf(t,2)*(1-t)*c +
			powf(t,3)*d );
}

void bezierSample(Path* path, CGPoint controlPoints[4], unsigned int sampleCount)
{
	for( int s = 0; s < sampleCount; ++s )
	{
		float t = (float)s / sampleCount;
		
		CGPoint p;
		p.x = bezierat(controlPoints[0].x, controlPoints[1].x, controlPoints[2].x, controlPoints[3].x, t);
		p.y = bezierat(controlPoints[0].y, controlPoints[1].y, controlPoints[2].y, controlPoints[3].y, t);
		[path addPoint:p];
	}
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( ![super init] )
		return nil;
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	self.anchorPoint = ccp(0, 0);
	
	
	bmpFont = [[CCLabelBMFont alloc] initWithString:@"Text on a bezier!!" fntFile:@"bitmapFontTest4.fnt"];
	[self addChild:bmpFont z:5];
	bmpFont.anchorPoint =self.anchorPoint;
	bmpFont.position = self.position;
	
	[bmpFont release];
	
	CGPoint controlPoints[4] = 
	{
		{ winSize.width - 10, 20 },		
		{ winSize.width * 0.666666, winSize.height * 0.75f },
		{ winSize.width * 0.333333, winSize.height * 0.75f },
		{ -10, 20 },
	};

	path = [[Path alloc] initWithCapacity:kBezierSamples];
	bezierSample(path, controlPoints, kBezierSamples);
	
	int letterCount = bmpFont.children.count;
	
	NSMutableArray* originalDistances = [[NSMutableArray alloc] initWithCapacity:letterCount];
	[originalDistances addObject:[NSNumber numberWithFloat:0.0f]];
	
	for( int c = 1; c < letterCount; ++c )
	{
		CCNode* child = [bmpFont.children objectAtIndex:c];
		CCNode* prevChild = [bmpFont.children objectAtIndex:c-1];
		[originalDistances addObject:[NSNumber numberWithFloat:ccpDistance(prevChild.position, child.position)]];
	}	
	
	float endPosition = path.length - 15.0f;
	bezierData = malloc(sizeof(SSpriteBezierData) * letterCount);	
	
	for( int c = 0; c < letterCount; ++c )
	{
		CCNode* child = [bmpFont.children objectAtIndex:c];		
		float originalDist = [[originalDistances objectAtIndex:c] floatValue];
		
		endPosition -= originalDist;
		
		child.position = [path pointAtIndex:0];	
		child.visible = NO;
		
		bezierData[c].position = 0;
		bezierData[c].endPosition = endPosition;
		bezierData[c].pathIndex = 0;
		bezierData[c].pathIndexPosition = 0;
		bezierData[c].maxDistToNext = originalDist;
	}
	
	[originalDistances release];
	
	[self schedule:@selector(updateBezierText:)];
	
	return self;
}

BOOL floatEqual(float n1, float n2)
{
	return fabs(n1 - n2) < FLT_EPSILON;	
}

-(void)updateBezierText:(ccTime)dt
{	
	for( int c = 0; c < bmpFont.children.count; ++c )
	{	
		CCNode* child = [bmpFont.children objectAtIndex:c];
		SSpriteBezierData* bd = &bezierData[c];
		
		float pathPos = bd->position;
		
		if( c > 0 )
		{
			SSpriteBezierData* pbd = &bezierData[c-1];
			
			float dist = pbd->position - bd->position;
			
			if( dist > bd->maxDistToNext )
				pathPos += (dist - bd->maxDistToNext);
		}
		else
		{
			pathPos += kSpeed * dt;
		}
		
		if( pathPos > 0 )
			child.visible = YES;
		
		pathPos = MIN(pathPos, bd->endPosition);
	
		CGPoint dest = child.position;
		
		if( pathPos > bd->position )
		{
			CGPoint curPoint = [path pointAtIndex:bd->pathIndex];
			CGPoint nextPoint = [path pointAtIndex:bd->pathIndex+1];
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
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	[path release];
	free(bezierData);
	
	[super dealloc];
}
@end
