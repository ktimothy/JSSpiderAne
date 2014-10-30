//
//  API.cpp
//  JSSpiderANE
//
//  Created by admin on 24.10.14.
//  Copyright (c) 2014 PeyTy. All rights reserved.
//

#define J

#import "FlashRuntimeExtensions.h"

#ifdef J
#define RELEASE
#undef DEBUG
#undef J
#include "jsapi.h"
using namespace JS;
#define J
#endif

#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

#define MAP_FUNCTION(fn, data) { (const uint8_t*)(#fn), (data), &(fn) }

#define MAP_FUNCTION_NAMED(named, fn, data) { named, (data), &(fn) }

#define DISPATCH_STATUS_EVENT(extensionContext, code, level) FREDispatchStatusEventAsync((extensionContext), (uint8_t*)code, (uint8_t*)level)

// Globalvar

#ifdef J
/* The class of the global object. */
static JSClass global_class = {
    "window",
    JSCLASS_GLOBAL_FLAGS,
    JS_PropertyStub,
    JS_DeletePropertyStub,
    JS_PropertyStub,
    JS_StrictPropertyStub,
    JS_EnumerateStub,
    JS_ResolveStub,
    JS_ConvertStub
};

JSRuntime *rt;
JSContext *cx;
RootedObject * global = NULL;
JSObject * globalObj = NULL;
#endif

FREContext contextCache;

// The error reporter callback.
void reportError(JSContext *cx, const char *message, JSErrorReport *report) {
    char buff[4096];
    sprintf(buff, "%s:%u:%s\n", report->filename ? report->filename : "[no filename]",
            (unsigned int) report->lineno,
            message);
    JS_GC(rt); // clean up memory
    DISPATCH_STATUS_EVENT(contextCache, buff, "error");
}

bool myjs_airi(JSContext *cx, unsigned int argc, jsval *vp)
{
}

static JSFunctionSpec myjs_global_functions[] = {
    JS_FS("callAIRI", myjs_airi, 2, 0),
    JS_FS_END
};

extern "C" {
DEFINE_ANE_FUNCTION(eval)
{
    contextCache = context;
    #ifdef J
    // To be filled
    uint32_t scriptLength;
    const uint8_t *script;
    FREGetObjectAsUTF8(argv[0], &scriptLength, &script);
    
    // Evaluate script.
    const char *bytes = reinterpret_cast<const char*>(script);
    JS::Value rval;

    JS::RootedObject global(cx, globalObj);
    JSAutoCompartment ac(cx, global);
    JS_InitStandardClasses(cx, global);
        
    JS_EvaluateScript(cx, global, bytes, scriptLength, nullptr, 0, &rval);
    #endif
    return nullptr;
}

DEFINE_ANE_FUNCTION(call)
{
    contextCache = context;
    #ifdef J
    // To be filled
    uint32_t scriptLength;
    const uint8_t *script;
    FREGetObjectAsUTF8(argv[0], &scriptLength, &script);
    
    // Evaluate script.
    FREObject retVal;
    JS::Value rval;
    bool ok;
  
    JS::RootedObject global(cx, globalObj);
    JSAutoCompartment ac(cx, global);
//    JS_InitStandardClasses(cx, global);
        
    ok = JS_EvaluateScript(cx, global, reinterpret_cast<const char*>(script), scriptLength, nullptr, 0, &rval);
    
    if (rval.isNullOrUndefined())// | rval.isFalse() )
    {
        FRENewObjectFromUTF8(4, (const uint8_t*)"null", &retVal);
        return retVal;
    }
    
    // Convert result to string
    if (ok) {
        JSString *str = rval.toString();
        char* buffer = JS_EncodeString(cx, str);
        FRENewObjectFromUTF8(
                             JS_GetStringEncodingLength(cx, str),
                             (const uint8_t*)buffer,
                             &retVal);
        free(buffer);
    } else {
        FRENewObjectFromUTF8(9, (const uint8_t*)"undefined", &retVal);
    }
    JS_free(cx, &rval);
    return retVal;
    #endif
    return nullptr;
}
} // extern C
// A native context instance is created
void ExtensionContextInitializer(void* extData,
                                 const uint8_t* ctxType,
                                 FREContext ctx,
                                 uint32_t* numFunctionsToSet,
                                 const FRENamedFunction** functionsToSet){
    
    // Initialize the native context.
    static FRENamedFunction functionMap[] =
    {
        MAP_FUNCTION_NAMED((const uint8_t*)"eval", eval, nullptr),
        MAP_FUNCTION_NAMED((const uint8_t*)"call", call, nullptr)
    };
    
    *numFunctionsToSet = sizeof( functionMap ) / sizeof( FRENamedFunction );
	*functionsToSet = functionMap;
    
    // Create JavaScript execution context.
    #ifdef J

    JS_Init();
    
    rt = JS_NewRuntime(8L * 1024 * 1024, JS_NO_HELPER_THREADS);
    if (!rt) return ;
    
    cx = JS_NewContext(rt, 8192);
    if (!cx) return ;

    JS_SetErrorReporter(cx, reportError);
    
    globalObj = JS_NewGlobalObject(cx, &global_class, nullptr, JS::DontFireOnNewGlobalHook);
    
    JS::RootedObject _global(cx, globalObj);
    if (!_global) return ;
    
    JSAutoCompartment ac(cx, _global);
    JS_InitStandardClasses(cx, _global);
    
    JS_DefineFunctions(cx, _global, myjs_global_functions);
    
    global = &_global;
    #endif
}

void ExtensionContextFinalizer(FREContext ctx)
{
	// Release JavaScript execution context.
    #ifdef J
    JS_DestroyContext(cx);
    JS_DestroyRuntime(rt);
    JS_ShutDown();
    #endif
}

extern "C"
{
// Initialization function of each extension
void JSSpiderANEExtensionInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet) {
	*extDataToSet = nullptr;
	*ctxInitializerToSet = &ExtensionContextInitializer;
	*ctxFinalizerToSet = &ExtensionContextFinalizer;
}

// Called when extension is unloaded
void JSSpiderANEExtensionFinalizer(void* extData) {
	return;
}
} // extern C