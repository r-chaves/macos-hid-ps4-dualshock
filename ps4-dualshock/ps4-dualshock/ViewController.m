//
//  ViewController.m
//  ps4-dualshock
//
//  Created by Ryan Chaves on 2/4/17.
//  Copyright © 2017 Ryan Chaves. All rights reserved.
//

#import "ViewController.h"
#import <IOKit/hid/IOHIDManager.h>
#import "HidElementData.h"

@interface ViewController()
@property NSMutableDictionary *ds4_list;
@end

static void handle_device_match
(
    void *          inContext,          // context from IOHIDManagerRegisterDeviceMatchingCallback
    IOReturn        inResult,           // the result of the matching operation
    void *          inSender,           // the IOHIDManagerRef for the new device
    IOHIDDeviceRef  inIOHIDDeviceRef    // the new HID device
);

static void handle_device_removal
(
    void *          inContext,          // context from IOHIDManagerRegisterDeviceMatchingCallback
    IOReturn        inResult,           // the result of the removing operation
    void *          inSender,           // the IOHIDManagerRef for the device being removed
    IOHIDDeviceRef  inIOHIDDeviceRef    // the removed HID device
);

static void handle_device_input
(
    void *          inContext,          // context from IOHIDDeviceRegisterInputValueCallback
    IOReturn        inResult,           // completion result for the input value operation
    void *          inSender,           // IOHIDDeviceRef of the device this element is from
    IOHIDValueRef   inValue             // the new element value
);

static void handle_device_report
(
    void * _Nullable    context,
    IOReturn            result,
    void * _Nullable    sender,
    IOHIDReportType     type,
    uint32_t            reportID,
    uint8_t *           report,
    CFIndex             reportLength
);

@implementation ViewController
{
    IOHIDManagerRef hid_manager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.ds4_list = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    hid_manager =
        IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
    
    NSArray *matchingTypes =
    @[
        @{
            @ kIOHIDDeviceUsagePageKey : @(kHIDPage_GenericDesktop),
            @ kIOHIDDeviceUsageKey     : @(kHIDUsage_GD_Joystick)
        },
        @{
            @ kIOHIDDeviceUsagePageKey : @(kHIDPage_GenericDesktop),
            @ kIOHIDDeviceUsageKey     : @(kHIDUsage_GD_GamePad)
        },
        @{
            @ kIOHIDDeviceUsagePageKey : @(kHIDPage_GenericDesktop),
            @ kIOHIDDeviceUsageKey     : @(kHIDUsage_GD_MultiAxisController)
        }
    ];
    
    IOHIDManagerRegisterDeviceMatchingCallback(
        hid_manager, handle_device_match, (__bridge void * _Nullable)(self));
    IOHIDManagerRegisterDeviceRemovalCallback(
        hid_manager, handle_device_removal, (__bridge void * _Nullable)(self));
    IOHIDManagerSetDeviceMatchingMultiple(
        hid_manager, (__bridge CFArrayRef)matchingTypes);
    IOHIDManagerScheduleWithRunLoop(
        hid_manager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    IOHIDManagerOpen(hid_manager, kIOHIDOptionsTypeNone);
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

static void handle_device_match
(
    void *          inContext,
    IOReturn        inResult,
    void *          inSender,
    IOHIDDeviceRef  inIOHIDDeviceRef
)
{
    /* TODO This needs to be tracked per device. */
//    static uint8_t report[64];
    
    printf("%s(context: %p, result: %i, sender: %p, device: %p).\n",
        __PRETTY_FUNCTION__, inContext, inResult, inSender, inIOHIDDeviceRef);
    ViewController *self = (__bridge ViewController *)inContext;
    [self.ds4_list setObject:[[NSMutableDictionary alloc] initWithCapacity:0]
                      forKey:IOHIDDeviceGetProperty(inIOHIDDeviceRef,
                                                    CFSTR(kIOHIDSerialNumberKey))];
    IOHIDDeviceRegisterInputValueCallback(
        inIOHIDDeviceRef, handle_device_input, inContext);
//    IOHIDDeviceRegisterInputReportCallback(inIOHIDDeviceRef, report, 64, handle_device_report, inContext);
}

static void handle_device_removal
(
    void *          inContext,
    IOReturn        inResult,
    void *          inSender,
    IOHIDDeviceRef  inIOHIDDeviceRef
)
{
    printf("%s(context: %p, result: %i, sender: %p, device: %p).\n",
        __PRETTY_FUNCTION__, inContext, inResult, inSender, inIOHIDDeviceRef);
    ViewController *self = (__bridge ViewController *)inContext;
    [self.ds4_list removeObjectForKey:IOHIDDeviceGetProperty(inIOHIDDeviceRef, CFSTR(kIOHIDSerialNumberKey))];
    IOHIDDeviceRegisterInputValueCallback(inIOHIDDeviceRef, NULL, inContext);
}

static void handle_device_input
(
    void *          inContext,
    IOReturn        inResult,
    void *          inSender,
    IOHIDValueRef   inValue
)
{
    ViewController *self = (__bridge ViewController *)inContext;

    const uint64_t timestamp = IOHIDValueGetTimeStamp(inValue);
    const CFIndex length = IOHIDValueGetLength(inValue);
    const uint8_t *byte_ptr = IOHIDValueGetBytePtr(inValue);
    const CFIndex value = IOHIDValueGetIntegerValue(inValue);
    const double_t scaled_value = IOHIDValueGetScaledValue(inValue, kIOHIDValueScaleTypePhysical);

//    printf("Value:: timestamp:%lli, length:%li, value:%li\n", timestamp, length, value);
    
    const IOHIDElementRef elem = IOHIDValueGetElement(inValue);
    const IOHIDElementCookie cookie = IOHIDElementGetCookie(elem);
    const IOHIDElementType type = IOHIDElementGetType(elem);
    const IOHIDElementCollectionType collection_type = IOHIDElementGetCollectionType(elem);
    const uint32_t usage_page = IOHIDElementGetUsagePage(elem);
    const uint32_t usage = IOHIDElementGetUsage(elem);
    const Boolean is_virtual = IOHIDElementIsVirtual(elem);
    const Boolean is_relative = IOHIDElementIsRelative(elem);
    const Boolean is_wrapping = IOHIDElementIsWrapping(elem);
    const Boolean is_array = IOHIDElementIsArray(elem);
    const Boolean is_nonlinear = IOHIDElementIsNonLinear(elem);
    const Boolean has_preferred_state = IOHIDElementHasPreferredState(elem);
    const Boolean has_null_state = IOHIDElementHasNullState(elem);
    const CFStringRef name = IOHIDElementGetName(elem);
    const uint32_t report_id = IOHIDElementGetReportID(elem);
    const uint32_t report_size = IOHIDElementGetReportSize(elem);
    const uint32_t report_count = IOHIDElementGetReportCount(elem);
    const uint32_t unit = IOHIDElementGetUnit(elem);
    const uint32_t unit_exponent = IOHIDElementGetUnitExponent(elem);
    const CFIndex logical_min = IOHIDElementGetLogicalMin(elem);
    const CFIndex logical_max = IOHIDElementGetLogicalMax(elem);
    const CFIndex physical_min = IOHIDElementGetPhysicalMin(elem);
    const CFIndex physical_max = IOHIDElementGetPhysicalMax(elem);
    
//    printf("cookie=%d, usage_page=%u, usage=0x%x, unit=%u, length=%ld\n\n",
//           cookie, usage_page, usage, unit, length);

    HidElementData *h = [HidElementData alloc];
    h.type = type;
    h.collection_type = collection_type;
    h.usage_page = usage_page;
    h.usage = usage;
    h.is_virtual = is_virtual;
    h.is_relative = is_relative;
    h.is_wrapping = is_wrapping;
    h.is_array = is_array;
    h.is_nonlinear = is_nonlinear;
    h.has_preferred_state = has_preferred_state;
    h.has_null_state = has_null_state;
    h.name = name;
    h.report_id = report_id;
    h.report_size = report_size;
    h.report_count = report_count;
    h.unit = unit;
    h.unit_exponent = unit_exponent;
    h.logical_min = logical_min;
    h.logical_max = logical_max;
    h.physical_min = physical_min;
    h.physical_max = physical_max;
    
//    NSMutableDictionary *v2 = [self.ds4_list objectForKey:IOHIDDeviceGetProperty(inSender, CFSTR(kIOHIDSerialNumberKey))];
    [[self.ds4_list objectForKey:IOHIDDeviceGetProperty(inSender, CFSTR(kIOHIDSerialNumberKey))] setObject:h forKey:[NSNumber numberWithInt:cookie]];
//    [v2 setObject:h forKey:[NSNumber numberWithInt:cookie]];
}

static void handle_device_report
(
    void * _Nullable    context,
    IOReturn            result,
    void * _Nullable    sender,
    IOHIDReportType     type,
    uint32_t            reportID,
    uint8_t *           report,
    CFIndex             reportLength
)
{
    ViewController *self = (__bridge ViewController *)context;
//    printf("%s(context: %p, result: %i, sender: %p, type: %i, reportID:%i).\n\treport:",
//           __PRETTY_FUNCTION__, context, result, sender, type, reportID);
//    for(int i = 0; i < reportLength; ++i)
//    {
//        printf(" 0x%02x", report[i]);
//    }
}

@end
