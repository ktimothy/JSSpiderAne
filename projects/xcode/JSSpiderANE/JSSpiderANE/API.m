//
//  API.cpp
//  JSSpiderANE
//

#import "FlashRuntimeExtensions.h"

#define RELEASE
#undef DEBUG
#include "jsapi.h"
using namespace JS;
#define JSBool bool
#define JS_TRUE true
#define JS_FALSE false

#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

#define MAP_FUNCTION(fn, data) { (const uint8_t*)(#fn), (data), &(fn) }

#define MAP_FUNCTION_NAMED(named, fn, data) { named, (data), &(fn) }

#define DISPATCH_STATUS_EVENT(extensionContext, code, level) FREDispatchStatusEventAsync((extensionContext), (uint8_t*)code, (uint8_t*)level)

// Globalvar

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

FREContext contextCache;

// The error reporter callback.
void reportError(JSContext *cx, const char *message, JSErrorReport *report) {
    char buff[4096];
    sprintf(buff, "%s:%u:%s\n", report->filename ? report->filename : "[no filename]",
            (unsigned int) report->lineno,
            message);
    DISPATCH_STATUS_EVENT(contextCache, buff, "error");
}

JSBool myjs_airi(JSContext *cx, unsigned int argc, jsval *vp)
{
}


extern "C" {
DEFINE_ANE_FUNCTION(eval)
{

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
		MAP_FUNCTION_NAMED((const uint8_t*)"eval", eval, nullptr)
	};

	*numFunctionsToSet = sizeof( functionMap ) / sizeof( FRENamedFunction );
	*functionsToSet = functionMap;

	// Create JavaScript execution context.

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
	JSFunctionSpec myjs_global_functions[] = { JS_FS("callAIRI", myjs_airi, 2, 0) };
	JS_DefineFunctions(cx, _global, myjs_global_functions);

	global = &_global;
}

void ExtensionContextFinalizer(FREContext ctx)
{
	// Release JavaScript execution context.
	JS_DestroyContext(cx);
	JS_DestroyRuntime(rt);
	JS_ShutDown();
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