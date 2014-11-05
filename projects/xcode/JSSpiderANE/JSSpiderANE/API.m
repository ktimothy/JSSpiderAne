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
char buffError[4096];
FREContext contextCache;
JSScript * preCompiledStringify;

// The error reporter callback.
void reportError(JSContext *cx, const char *message, JSErrorReport *report) {
	sprintf(buffError, "%s:%u:%s", report->filename ? report->filename : "[no filename]",
			(unsigned int) report->lineno,
			message);
	DISPATCH_STATUS_EVENT(contextCache, buffError, "error");
}

JSBool myjs_airi(JSContext *cx, unsigned int argc, jsval *vp)
{
	// get arguments
	JSString* name;
	JSString* params;

	char *cname;
	char *cparams;
	size_t cparams_size;

	if (!JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "SS", &name, &params)) return false;

	cname = JS_EncodeString(cx, name);
	cparams = JS_EncodeString(cx, params);
	cparams_size = JS_GetStringEncodingLength(cx, params);


	DISPATCH_STATUS_EVENT(contextCache, cname, "error");
	DISPATCH_STATUS_EVENT(contextCache, cparams, "error");

	const uint8_t *cresult;
	uint32_t cresult_size;

	// convert strings
	FREObject freparams;
	FRENewObjectFromUTF8(cparams_size, (const uint8_t*)cparams, &freparams);

	// call AS3
	FREObject freas3, freresult, thrownException;

	FRENewObjectFromUTF8(4, (const uint8_t*)"null", &freresult);

	auto isOk = FREGetContextActionScriptData(contextCache, &freas3);

	if(isOk == FRE_WRONG_THREAD) DISPATCH_STATUS_EVENT(contextCache, "FREGetContextActionScriptData FRE_WRONG_THREAD", "error"); else
	if(isOk == FRE_INVALID_ARGUMENT) DISPATCH_STATUS_EVENT(contextCache, "FREGetContextActionScriptData FRE_INVALID_ARGUMENT", "error");

	FRESetObjectProperty(freas3,
						 (const uint8_t*)cname,
						 freparams,
						 &thrownException
						 );

	FREObjectType type;

	isOk = FREGetObjectType(freas3, &type);

	if(type != FRE_TYPE_OBJECT) DISPATCH_STATUS_EVENT(contextCache, "FREGetObjectType is NOT FRE_TYPE_OBJECT", "error");
	if(isOk != FRE_OK) DISPATCH_STATUS_EVENT(contextCache, "FREGetObjectType failed", "error");

	isOk = FREGetObjectProperty(freas3,
						 (const uint8_t*)cname,
						 &freresult,
						 &thrownException
						 );

	if(isOk != FRE_OK) {
		if(isOk == FRE_NO_SUCH_NAME) DISPATCH_STATUS_EVENT(contextCache, "FRE_NO_SUCH_NAME", "error");
		if(isOk == FRE_INVALID_OBJECT) DISPATCH_STATUS_EVENT(contextCache, "FRE_INVALID_OBJECT", "error");
		if(isOk == FRE_TYPE_MISMATCH) DISPATCH_STATUS_EVENT(contextCache, "FRE_TYPE_MISMATCH", "error");
		if(isOk == FRE_ACTIONSCRIPT_ERROR) DISPATCH_STATUS_EVENT(contextCache, "FRE_ACTIONSCRIPT_ERROR", "error");
		if(isOk == FRE_INVALID_ARGUMENT) DISPATCH_STATUS_EVENT(contextCache, "FRE_INVALID_ARGUMENT", "error");
		if(isOk == FRE_READ_ONLY) DISPATCH_STATUS_EVENT(contextCache, "FRE_READ_ONLY", "error");
		if(isOk == FRE_WRONG_THREAD) DISPATCH_STATUS_EVENT(contextCache, "FRE_WRONG_THREAD", "error");
		if(isOk == FRE_ILLEGAL_STATE) DISPATCH_STATUS_EVENT(contextCache, "FRE_ILLEGAL_STATE", "error");
		if(isOk == FRE_INSUFFICIENT_MEMORY) DISPATCH_STATUS_EVENT(contextCache, "FRE_INSUFFICIENT_MEMORY", "error");
	}

	// convert result
	FREGetObjectAsUTF8(freresult, &cresult_size, &cresult);
	JSString * resultStr = JS_NewStringCopyN(cx, (const char*)cresult, cresult_size);

	JS_SET_RVAL(cx, vp, STRING_TO_JSVAL(resultStr));
	return JS_TRUE;
}

JSFunctionSpec myjs_global_functions[] = { JS_FS("callAIRI", myjs_airi, 2, 0), JS_FS_END };

extern "C" {
DEFINE_ANE_FUNCTION(eval)
{
	contextCache = context;
	// To be filled
	uint32_t scriptLength;
	const uint8_t *script;
	FREGetObjectAsUTF8(argv[0], &scriptLength, &script);

	// Evaluate script.
	FREObject retVal;
	JS::Value rval;

	JS::RootedObject global(cx, globalObj);
	JSAutoCompartment ac(cx, global);

	bool ok = JS_EvaluateScript(cx, global, reinterpret_cast<const char*>(script), scriptLength, nullptr, 0, &rval);

	// All ok and nothing to return
	if(ok) if(rval.isNullOrUndefined())
	{
		FRENewObjectFromUTF8(15, (const uint8_t*)"{\"result\":null}", &retVal);
		return retVal;
	}

	// Create resulting object
	JSObject * resultContainerObj = JS_NewObject(cx, NULL, NULL, NULL);
	JS::Value resultContainer = OBJECT_TO_JSVAL(resultContainerObj);
	JS::Handle<JS::Value> resultContainerv = HandleValue::fromMarkedLocation(&resultContainer);

	// All ok and we have a result...
	if(ok) {
		JS::Handle<JS::Value> v = HandleValue::fromMarkedLocation(&rval);
		JS_SetProperty(cx, resultContainerObj, (const char *)"result", v);
	}

	// ...otherwise
	else {
		JSString * errstr = JS_NewStringCopyN(cx, buffError, 4096);
		JS::Value errval = JS::StringValue(errstr);
		JS::Handle<JS::Value> v = HandleValue::fromMarkedLocation(&errval);
		JS_SetProperty(cx, resultContainerObj, (const char *)"error", v);
	}

	// Stringify result to JSON string
	JS::Value rval2;

	JS_SetProperty(cx, globalObj, (const char *)"t", resultContainerv);

	if(!JS_ExecuteScript(cx, global, preCompiledStringify, &rval2)) return NULL;

	JSString *str = rval2.toString();

	// Convert result to AS3 string
	FRENewObjectFromUTF8(
						 JS_GetStringEncodingLength(cx, str),
						 (const uint8_t*)JS_EncodeString(cx, str),
						 &retVal);

	// Done
	return retVal;
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

	rt = JS_NewRuntime(8L * 1024 * 1024 * 2, JS_NO_HELPER_THREADS);
	if (!rt) return ;

	cx = JS_NewContext(rt, 8192 * 2);
	if (!cx) return ;

	JS_SetErrorReporter(cx, reportError);

	globalObj = JS_NewGlobalObject(cx, &global_class, nullptr, JS::DontFireOnNewGlobalHook);

	JS::RootedObject _global(cx, globalObj);
	if (!_global) return ;

	JSAutoCompartment ac(cx, _global);
	JS_InitStandardClasses(cx, _global);

	JS_DefineFunctions(cx, _global, myjs_global_functions);

	global = &_global;

	// Precompile JSON-script:
	JS::Value rval;
	JS_EvaluateScript(cx, _global, (const char *)"t={}", 4, nullptr, 0, &rval);
	JS::HandleObject obj = HandleObject::fromMarkedLocation(&globalObj);
	const JS::CompileOptions options(cx);
	preCompiledStringify = JS_CompileScript(cx, obj, (const char *)"JSON.stringify(t)", 17, options);
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