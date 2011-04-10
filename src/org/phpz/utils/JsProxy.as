package org.phpz.utils 
{
    import flash.external.ExternalInterface;
	/**
     * JS 代理
     * @author Seven Yu
     */
    public class JsProxy
    {
        private static var jsFunc:String;
        private static var funcDict:Object = {};
        
        /**
         * 初始化
         * @param	fn  js 函数名
         */
        public static function init(fn:String = null):void
        {
            jsFunc = fn;
            available && ExternalInterface.addCallback('exec', run);
        }
        
        /**
         * flash 调 js
         * @param	func   方法名
         * @param	args   参数
         * @return
         */
        public static function call(func:String, args:* = null):*
        {
            if (available)
            {
                //return ExternalInterface.call(jsFunc, func, args);
                return ExternalInterface.call(jsFunc + '.' + func, args); // for old upload page js object
            }
            return false;
        }
        
        /**
         * js 调 flash
         * @param	key    方法名
         * @param	args   参数
         * @return
         */
        public static function run(key:String, args:*= null):*
        {
            if (funcDict[key])
            {
                return funcDict[key](args);
            }
            else
            {
                return null;
            }
        }
        
        /**
         * 注册 flash 方法
         * @param	key    方法 id
         * @param	func   方法实现
         */
        public static function register(key:String, func:Function):void
        {
            funcDict[key] = func;
        }
        
        /**
         * 卸载 flash 方法
         * @param	key    方法 id
         */
        public static function unregister(key:String):void
        {
            delete funcDict[key];
        }
        
        /**
         * js 是否可用
         */
        public static function get available():Boolean
        {
            return jsFunc && ExternalInterface.available;
        }
        
    }

}