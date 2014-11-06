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

JSBool callAIRI(JSContext *cx, unsigned int argc, jsval *vp)
{
	goto runFunc;

// internal exceptions handling

	char buffError[4096];
	char * error;

internalException:
	if(!error) error = (char *)"internal exception";

	sprintf(buffError, "%s%s%s", "{ \"result\": null, \"error\": \"", error, "\" }");

	JSString * errorStr;
	errorStr = JS_NewStringCopyZ(cx, (const char*)buffError);

	JS_SET_RVAL(cx, vp, STRING_TO_JSVAL(errorStr));
	return JS_TRUE;

runFunc:
	error = NULL;

	// get arguments
	JSString* params;

	char *cparams;
	size_t cparams_size;

	if (!JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "S", &params)) { error = (char *)"JS_ConvertArguments failed"; goto internalException; }

	cparams = JS_EncodeString(cx, params);
	cparams_size = JS_GetStringEncodingLength(cx, params);



	const uint8_t *cresult;
	uint32_t cresult_size;

	// convert strings
	FREObject freparams;
	FRENewObjectFromUTF8(cparams_size, (const uint8_t*)cparams, &freparams);

	// call AS3
	FREObject freas3, freresult, thrownException;


	auto isOk = FREGetContextActionScriptData(contextCache, &freas3);

	if(isOk == FRE_WRONG_THREAD) { error = (char *)"FREGetContextActionScriptData FRE_WRONG_THREAD"; goto internalException; } else
	if(isOk == FRE_INVALID_ARGUMENT) { error = (char *)"FREGetContextActionScriptData FRE_INVALID_ARGUMENT"; goto internalException; }

	FRESetObjectProperty(freas3,
						 (const uint8_t*)"run",
						 freparams,
						 &thrownException
						 );

	FREObjectType type;

	isOk = FREGetObjectType(freas3, &type);

	if(type != FRE_TYPE_OBJECT) { error = (char *)"FREGetObjectType is NOT FRE_TYPE_OBJECT"; goto internalException; }
	if(isOk != FRE_OK) { error = (char *)"FREGetObjectType failed"; goto internalException; }

	isOk = FREGetObjectProperty(freas3,
						 (const uint8_t*)"run",
						 &freresult,
						 &thrownException
						 );

	if(isOk != FRE_OK) {
		if(isOk == FRE_NO_SUCH_NAME) error = (char *)"FRE_NO_SUCH_NAME";
		if(isOk == FRE_INVALID_OBJECT) error = (char *)"FRE_INVALID_OBJECT";
		if(isOk == FRE_TYPE_MISMATCH) error = (char *)"FRE_TYPE_MISMATCH";
		if(isOk == FRE_ACTIONSCRIPT_ERROR) error = (char *)"FRE_ACTIONSCRIPT_ERROR";
		if(isOk == FRE_INVALID_ARGUMENT) error = (char *)"FRE_INVALID_ARGUMENT";
		if(isOk == FRE_READ_ONLY) error = (char *)"FRE_READ_ONLY";
		if(isOk == FRE_WRONG_THREAD) error = (char *)"FRE_WRONG_THREAD";
		if(isOk == FRE_ILLEGAL_STATE) error = (char *)"FRE_ILLEGAL_STATE";
		if(isOk == FRE_INSUFFICIENT_MEMORY) error = (char *)"FRE_INSUFFICIENT_MEMORY";
		goto internalException;
	}

	// convert result
	FREGetObjectAsUTF8(freresult, &cresult_size, &cresult);
	JSString * resultStr = JS_NewStringCopyN(cx, (const char*)cresult, cresult_size);

	JS_SET_RVAL(cx, vp, STRING_TO_JSVAL(resultStr));
	return JS_TRUE;
}


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
	JS::Value resultContainerValue = OBJECT_TO_JSVAL(resultContainerObj);
	JS::Handle<JS::Value> resultContainerHandle = HandleValue::fromMarkedLocation(&resultContainerValue);

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

	JS_SetProperty(cx, globalObj, (const char *)"_$", resultContainerHandle);

	if(!JS_ExecuteScript(cx, global, preCompiledStringify, &rval2)) {
		FRENewObjectFromUTF8(15, (const uint8_t*)"{\"error\":\"JS_ExecuteScript failed\"}", &retVal);
		return retVal;
	}
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

	JS_DefineFunction(cx, _global, (const char *)"callAIRI", callAIRI, 1, 0);

	global = &_global;

	// Precompile JSON-script:
	JS::Value rval;
	JS_EvaluateScript(cx, _global, (const char *)"_$={}", 5, nullptr, 0, &rval);
	JS::HandleObject obj = HandleObject::fromMarkedLocation(&globalObj);
	const JS::CompileOptions options(cx);
	preCompiledStringify = JS_CompileScript(cx, obj, (const char *)"JSON.stringify(_$)", 18, options);
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