//
//  HidElementData.h
//  ps4-dualshock
//
//  Created by Ryan Chaves on 2/12/17.
//  Copyright © 2017 Ryan Chaves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDManager.h>

@interface HidElementData : NSObject
@property IOHIDElementType type;
@property IOHIDElementCollectionType collection_type;
@property uint32_t usage_page;
@property uint32_t usage;
@property Boolean is_virtual;
@property Boolean is_relative;
@property Boolean is_wrapping;
@property Boolean is_array;
@property Boolean is_nonlinear;
@property Boolean has_preferred_state;
@property Boolean has_null_state;
@property CFStringRef name;
@property uint32_t report_id;
@property uint32_t report_size;
@property uint32_t report_count;
@property uint32_t unit;
@property uint32_t unit_exponent;
@property CFIndex logical_min;
@property CFIndex logical_max;
@property CFIndex physical_min;
@property CFIndex physical_max;
@end
