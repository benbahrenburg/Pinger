//
//  SimplePingHelper.h
//  PingTester
//
//  Created by Chris Hulbert on 18/01/12.
//

#import <Foundation/Foundation.h>
#import "SimplePing.h"

@interface SimplePingHelper : NSObject <SimplePingDelegate>{
@private
    SimplePing* _simplePing;
    id _target;
    SEL _sel;
    int _timeOut;
    NSDate* _startDate;
    NSString* _address;
}

+ (void)ping:(NSString*)address withTarget:(id)target withSel:(SEL)sel withTimeout:(int) timeout;

@end
