//
//  SimplePingHelper.m
//  PingTester
//
//  Created by Chris Hulbert on 18/01/12.
//

#import "SimplePingHelper.h"
#import "TiUtils.h"

@implementation SimplePingHelper

#pragma mark - Run it

// Pings the address, and calls the selector when done. Selector must take a NSnumber which is a bool for success
+ (void)ping:(NSString*)address withTarget:(id)target withSel:(SEL)sel withTimeout:(int) timeout
{
	// The helper retains itself through the timeout function
	[[[[SimplePingHelper alloc] initWithAddress:address withTarget:target withSel:sel withTimeout:timeout] autorelease] start];
}

#pragma mark - Init/dealloc

- (void)dealloc
{
    if(_simplePing!=nil){
        RELEASE_TO_NIL(_simplePing);
    }
    if(_target!=nil){
        RELEASE_TO_NIL(_target);
    }
    if(_address!=nil){
        RELEASE_TO_NIL(_address);
    }
    if(_startDate!=nil){
        RELEASE_TO_NIL(_startDate);
    }
	[super dealloc];
}

- (id)initWithAddress:(NSString*)address withTarget:(id)target withSel:(SEL)sel withTimeout:(int) timeout
{
	if (self = [self init]) {
        _address = [address retain];
		_simplePing = [[SimplePing simplePingWithHostName:[NSMutableString stringWithString: address]] retain];
		_simplePing.delegate = self;
		_target = [target retain];
		_sel = sel;
        _timeOut = timeout;
	}
	return self;
}

#pragma mark - Go

- (void)start
{
    if(_startDate!=nil){
        RELEASE_TO_NIL(_startDate);
    }
    _startDate = [[NSDate date] retain];
	[_simplePing start];
	[self performSelector:@selector(endTime) withObject:nil afterDelay:1]; // This timeout is what retains the ping helper
}

#pragma mark - Finishing and timing out

// Called on success or failure to clean up
- (void)stop
{
	[_simplePing stop];
	[[_simplePing retain] autorelease]; // In case, higher up the call stack, this got called by the simpleping object itself
	_simplePing = nil;
}

- (void) onFinish:(BOOL)success withMessage:(NSString*)message
{
    NSDate *methodFinish = [NSDate date];
	[self stop];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:_startDate];
    //NSLog(@"executionTime is: %f", executionTime);
    
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setObject:NUMBOOL(success) forKey:@"success"];
    [event setObject:message forKey:@"message"];
    [event setObject:_address forKey:@"address"];
    [event setObject:[NSNumber numberWithDouble:executionTime] forKey:@"duration"];
	[_target performSelector:_sel withObject:event];
}

// Called 1s after ping start, to check if it timed out
- (void)endTime
{
    // If it hasn't already been killed, then it's timed out
	if (_simplePing)
    {
		[self onFinish:NO withMessage:@"timeout"];
	}
}

#pragma mark - Pinger delegate

// When the pinger starts, send the ping immediately
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
{
	[_simplePing sendPingWithData:nil];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
{
	[self onFinish:NO withMessage:[error localizedDescription]];
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error
{
	[self onFinish:NO withMessage:@"No connection available, packets not sent"];
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet
{
	[self onFinish:NO withMessage:@"connected successfully"];
}
@end
