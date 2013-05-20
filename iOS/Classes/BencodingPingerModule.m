/**
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "BencodingPingerModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "SimplePingHelper.h"

@implementation BencodingPingerModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"6eb0b65c-49d9-461a-b4f6-3ba0928068f1";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"bencoding.pinger";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
    //[self clean];
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#define allTrim( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]
-(void) clean
{
    if(_methodCallback!=nil)
    {
        [_methodCallback release];
    }
}

-(void)ping:(id)args
{
    
    ENSURE_SINGLE_ARG(args,NSDictionary);
    
    //Make sure we're on the UI thread, this stops bad things
	ENSURE_UI_THREAD(ping,args);
    
    //Check that we have a callback
    if(![args objectForKey:@"completed"]){
        NSLog(@"The callback function completed is required");
        return;
    }
    
    //Fetch the callback function, remember to add retain since we are using deligates
    _methodCallback = [[args objectForKey:@"completed"] retain];
    
    //Check that an address is provided
    if(![args objectForKey:@"address"]){
        NSLog(@"The address property is required");
        return;
    }
    
    //Get the address from the dictionary
    NSString *address = [TiUtils stringValue:@"address" properties:args];
 
    NSRange rangeHTTP = [address rangeOfString:@"http://"];
    if (rangeHTTP.length > 0){
        [address stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    }
    NSRange rangeHTTPS = [address rangeOfString:@"https://"];
    if (rangeHTTPS.length > 0){
        [address stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    }
    
    address = allTrim(address);
    
    //If a timeout is provided, us the timeout from the user, otherwise use 5
    int timeout = [TiUtils intValue:@"timeout" properties:args def:5];
    
    [SimplePingHelper ping:address withTarget:self withSel:@selector(pingResult:) withTimeout:timeout];
}

- (void)pingResult:(NSMutableDictionary*)dict
{
    if(_methodCallback!=nil)
    {
        [self _fireEventToListener:@"completed"
                withObject:dict listener:_methodCallback thisObject:nil];
        [self clean];
    }
}
@end
