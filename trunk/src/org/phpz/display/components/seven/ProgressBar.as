package org.phpz.display.components.seven 
{
	import flash.display.Sprite;
	
	/**
     * ...
     * @author Seven Yu
     */
    public class ProgressBar extends Sprite 
    {
        
        private var _bottomBar:Sprite;
        private var _middleBar:Sprite;
        private var _maskBar:Sprite;
        private var _frontBar:Sprite;
        
        private var _percent:Number = 0;
        
        public function ProgressBar(frontBar:Sprite, maskBar:Sprite, middleBar:Sprite, bottomBar:Sprite) 
        {
            _frontBar = frontBar;
            _maskBar = maskBar;
            _middleBar = middleBar;
            _bottomBar = bottomBar;
            
            addChild(_bottomBar);
            addChild(_middleBar);
            addChild(_maskBar);
            addChild(_frontBar);
            
            _middleBar.mask = _maskBar;
        }
        
        override public function set width(value:Number):void
        {
            _bottomBar.width = _maskBar.width = _frontBar.width = value;
            percent = _percent;
        }
        
        public function get percent():Number 
        {
            return _percent;
        }
        
        public function set percent(value:Number):void 
        {
            _percent = Math.min(100, Math.max(0, value));
            _middleBar.width = _maskBar.width * _percent;
        }
        
    }

}