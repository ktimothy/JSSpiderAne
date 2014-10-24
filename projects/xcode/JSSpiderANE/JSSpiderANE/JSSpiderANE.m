//
//  JSSpiderANE.m
//  JSSpiderANE
//
//  Created by admin on 24.10.14.
//  Copyright (c) 2014 PeyTy. All rights reserved.
//

#import "JSSpiderANE.h"

#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

#define MAP_FUNCTION(fn, data) { (const uint8_t*)(#fn), (data), &(fn) }

#define MAP_FUNCTION_NAMED(named, fn, data) { named, (data), &(fn) }

#define DISPATCH_STATUS_EVENT(extensionContext, code, level) FREDispatchStatusEventAsync((extensionContext), (uint8_t*)code, (uint8_t*)level)

@implementation JSSpiderANE

@end
