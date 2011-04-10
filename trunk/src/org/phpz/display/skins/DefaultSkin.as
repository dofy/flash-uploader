package org.phpz.display.skins 
{
    import flash.display.Sprite;
    
	/**
     * 样式元件定义
     * @author Seven Yu
     */
    public class DefaultSkin
    {
        // select button
        public const btnSelectUp:Sprite = new BtnSelectUp();
        public const btnSelectOver:Sprite = new BtnSelectOver();
        public const btnSelectDown:Sprite = new BtnSelectDown();
        public const btnSelectDisable:Sprite = new BtnSelectDisable();
        
        // cancel button
        public const btnCancelUp:Sprite = new BtnCancelUp();
        public const btnCancelOver:Sprite = new BtnCancelOver();
        public const btnCancelDown:Sprite = new BtnCancelDown();
        public const btnCancelDisable:Sprite = new BtnCancelDisable();
        
        // progress bar
        public const progressBottomBar:Sprite = new ProgressBottomBar();
        public const progressMiddleBar:Sprite = new ProgressMiddleBar();
        public const progressMaskBar:Sprite = new ProgressMaskBar();
        public const progressFrontBar:Sprite = new ProgressFrontBar();
        
    }

}