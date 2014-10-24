//
//  JSSpiderANE.m
//  JSSpiderANE
//
//  Created by admin on 24.10.14.
//  Copyright (c) 2014 PeyTy. All rights reserved.
//

#import "JSSpiderANE.h"
#import "FlashRuntimeExtensions.h"

#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

#define MAP_FUNCTION(fn, data) { (const uint8_t*)(#fn), (data), &(fn) }

#define MAP_FUNCTION_NAMED(named, fn, data) { named, (data), &(fn) }

#define DISPATCH_STATUS_EVENT(extensionContext, code, level) FREDispatchStatusEventAsync((extensionContext), (uint8_t*)code, (uint8_t*)level)

@implementation JSSpiderANE

@end

// Globalvar


DEFINE_ANE_FUNCTION(ADEPEval)
{
    // To be filled
    uint32_t string1Length;
    const uint8_t *string1;
    FREGetObjectAsUTF8(argv[0], &string1Length, &string1);
    
    // Evaluate script.

    return NULL;
}

DEFINE_ANE_FUNCTION(ADEPCall)
{
    // To be filled
    uint32_t string1Length;
    const uint8_t *string1;
    FREGetObjectAsUTF8(argv[0], &string1Length, &string1);
    
    // Evaluate script.
    
    
    // Convert result to string
    size_t bufferSize;
    char* buffer;
    
    
    FREObject retVal;
    FRENewObjectFromUTF8(bufferSize, (const uint8_t*)buffer, &retVal);
    free(buffer);
    return retVal;
}

// A native context instance is created
void ExtensionContextInitializer(void* extData,
                                 const uint8_t* ctxType,
                                 FREContext ctx,
                                 uint32_t* numFunctionsToSet,
                                 const FRENamedFunction** functionsToSet){
    
    // Initialize the native context.
    static FRENamedFunction functionMap[] =
    {
        MAP_FUNCTION_NAMED((const uint8_t*)"eval", ADEPEval, NULL),
        MAP_FUNCTION_NAMED((const uint8_t*)"call", ADEPCall, NULL)
    };
    
    *numFunctionsToSet = sizeof( functionMap ) / sizeof( FRENamedFunction );
	*functionsToSet = functionMap;
    
    // Create JavaScript execution context.
    
    // Initial script
   ("window = {};");
    // Evaluate script.
   
}

void ExtensionContextFinalizer(FREContext ctx)
{
	// Release JavaScript execution context.
    
}

// Initialization function of each extension
void JSSpiderANEExtensionInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet) {
	*extDataToSet = NULL;
	*ctxInitializerToSet = &ExtensionContextInitializer;
	*ctxFinalizerToSet = &ExtensionContextFinalizer;
}

// Called when extension is unloaded
void JSSpiderANEExtensionFinalizer(void* extData) {
	return;
}