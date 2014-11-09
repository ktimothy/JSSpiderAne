package alegorium
{
    import flash.events.StatusEvent;
    import flash.external.ExtensionContext;

    public class JSSpiderANE
    {
        private static var _context:ExtensionContext;
        private static var _exceptionListener:Function;

        public function JSSpiderANE()
        {
            throw new Error("JSSpiderANE instantiation is not allowed");
        }

        /**
         * Sets the exception listener
         *
         * @param listener Listener function that takes e:StatusEvent as argument
         */
        public static function setExceptionListener(listener:Function):void
        {
            if (_exceptionListener && _context)
            {
                _context.removeEventListener(StatusEvent.STATUS, _exceptionListener);
            }

            _exceptionListener = listener;

            if (_context)
            {
                _context.addEventListener(StatusEvent.STATUS, _exceptionListener);
            }
        }

        private static function getContext():ExtensionContext
        {
            if(_context != null) return _context;

            _context = ExtensionContext.createExtensionContext("alegorium.ane.JSSpiderANE", "");

            _context.actionScriptData = new MethodHolder();

            if (_exceptionListener != null)
            {
                _context.addEventListener(StatusEvent.STATUS, _exceptionListener);
            }

            return _context;
        }

        /**
         * Whether or not is it possible to run JS code on the current device
         */
        public static function get isSupported():Boolean
        {
            try
            {
                return getContext() != null;
            }
            catch(error:*)
            {
                trace(error);
            }

            return false;
        }

        /**
         * Script environment is the container of methods available to be
         * called by name from JS.
         * For example if you set a <code>flash.geom.Point</code> instance as a
         * script environment then you can call it's <code>normalize()</code>,
         * <code>offset()</code>, <code>polar()</code> and all other methods
         * right from JS.
         * There is a global <code>callAIR</code> function defined in JS to
         * give you access to the script environment. <code>callAIR</code>
         * function consumes two parameters: the name of AS3 method to call and
         * the argument object to pass to that AS3 method.
         * You can even get the AS3 method result in JS. <code>callAIR</code>
         * method in JS returns exactly the same with what AS3 method returns.
         * But be aware of JSON serialization taking place when transferring
         * objects between SpiderMonkey and AIR. It is not possible to pass a
         * working pointer to an object from one VM to another.
         *
         * @example Example script environment could be as simple as that:
         * <listing version="3.0">
         * var environment:Object = new Object();
         * environment["add"] = function(args:Object):int
         *                     {
         *                         return args["x"] +args["y"];
         *                     };
         * </listing>
         *
         * @example To call that script environment from JS do the following:
         * <listing version="3.0">
         * var operands = {x: 123, y: 321};
         * var addResult = callAIR("add", operands);
         * </listing>
         *
         *
         * @param object    Container object of methods available to be called
         *                  by name from JS.
         *
         */
        public static function setScriptEnvironment(object:Object):void
        {
            (getContext().actionScriptData as MethodHolder).holder = object;
        }

        /**
         * Run JS code and get the returned value. Basically this works like a
         * command-line interpreter. Please be careful with what your script
         * returns because JSON serialization is used on the intermediate level
         *
         * @param script    Any valid javascript code.
         *
         * @return          A value of type Boolean, Number, String, Array or
         *                  Object. Whatever your script ended up with.
         *                  Though Functions are excluded from the list because
         *                  they can not be stringified to JSON properly. So
         *                  are Errors too.
         *
         * @throws Error    An error that occured in SpiderMonkey during script
         *                  compilation or execution.
         */
        public static function evaluateScript(script:String):Object
        {
            if(_context == null) getContext();

            var callResultString:String = _context.call("eval", script) as String;
            var callResult:Object = JSON.parse(callResultString);

            if(callResult.error != null)
            {
                throw new Error(String(callResult.error));
            }

            return callResult.result;
        }

        /**
         * Frees extension memory and unloads JS engine
         */
        public static function dispose():void
        {
            if(_context == null) return;

            if (_exceptionListener != null)
            {
                _context.removeEventListener(StatusEvent.STATUS, _exceptionListener);
            }

            _exceptionListener = null;

            _context.dispose();
            _context = null;
        }
    }
}

internal final class MethodHolder
{
    public var holder:Object;

    private var _result:Object;

    public function get run():String
    {
        return JSON.stringify(_result);
    }

    public function set run(json:String):void
    {
        var callInfo:Object = JSON.parse(json);

        _result = { result: null, error: null };

        if(holder != null)
        {
            try
            {
                _result["result"] = holder[callInfo.name](callInfo.data);
            }
            catch(error:*)
            {
                _result["error"] = String(error);
            }
        }
        else
        {
            _result["error"] = "Script environment was not specified";
        }
    }
}
