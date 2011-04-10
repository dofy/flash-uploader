package org.phpz.comm 
{
	/**
     * FlashVars 公共类
     * @author Seven Yu
     */
    public class FlashVars 
    {
        
        private static var _data:Object = {};
        
        
        public static function set data(value:Object):void
        {
            _data = value;
        }
        
        public static function attr(key:String):*
        {
            return _data[key] || null;
        }
        
    }

}