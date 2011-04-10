package org.phpz.display.components.seven 
{
    import flash.display.DisplayObject;
    import flash.display.SimpleButton;
	import flash.display.Sprite;
    import flash.events.MouseEvent;
	
	/**
     * 简单按钮组件
     * @author Seven Yu
     */
    public class Button extends Sprite 
    {
        
        private var _normalButton:SimpleButton;
        private var _disableButton:Sprite;
        
        private var _enabled:Boolean = true;
        
        /**
         * 简单按钮组件
         * @param	upState      正常状态
         * @param	overState    悬停状态
         * @param	downState    按下状态
         * @param	disableState 不可用状态
         * @param	clickHandler 单击事件 (无法获得真正 event.target)
         */
        public function Button(upState:DisplayObject, overState:DisplayObject, downState:DisplayObject, disableState:DisplayObject, clickHandler:Function) 
        {
            _normalButton = new SimpleButton(upState, overState, downState, upState);
            _disableButton = disableState as Sprite;
            
            addChild(_normalButton);
            addChild(_disableButton);
            
            enabled = true;
            
            _normalButton.addEventListener(MouseEvent.CLICK, clickHandler);
        }
        
        /**
         * 设置/获取 按钮可用状态
         */
        public function get enabled():Boolean 
        {
            return _enabled;
        }
        
        public function set enabled(value:Boolean):void 
        {
            _enabled = value;
            _normalButton.visible = value;
            _disableButton.visible = !value;
        }
        
    }

}