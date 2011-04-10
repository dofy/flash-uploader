package 
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.DataEvent;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.MouseEvent;
    import flash.events.ProgressEvent;
    import flash.net.FileFilter;
    import flash.net.FileReference;
    import flash.net.URLRequest;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import org.phpz.comm.Config;
    import org.phpz.comm.FlashVars;
    import org.phpz.display.components.seven.Button;
    import org.phpz.display.components.seven.ProgressBar;
    import org.phpz.display.skins.DefaultSkin;
    import org.phpz.utils.JsProxy;
    import org.phpz.utils.Tool;
	
	/**
	 * Flash 上传控件
	 * @author Seven Yu
     * @uri http://code.google.com/p/flash-uploader/
	 */
	public class Main extends Sprite 
	{
		
        private const PADDING:int = 10;
        private const SMALL_PADDING:int = 3;

        private const TEXT_WIDTH:int = 200;
        private const TEXT_HEIGHT:int = 20;
        
        private var skin:DefaultSkin = new DefaultSkin();
        
        private var selectBtn:Button;
        private var cancelBtn:Button;
        private var progressBar:ProgressBar;

        private var txtPercent:TextField;
        private var txtSpeed:TextField;
        private var txtLeft:TextField;

        private var fileRef:FileReference = new FileReference();
        
        private var _time:Number;
        
        private var _types:Array;
        
        
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point

            // align && scale mode
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            stage.addEventListener(Event.RESIZE, resize);
            
            initConfig();
            initUI();
		}
        
        /**
         * 初始化配置
         */
        private function initConfig():void 
        {
            FlashVars.data = loaderInfo.parameters;
            
            JsProxy.init(FlashVars.attr('jsobj'));
            
            Config.id = FlashVars.attr('id');
            Config.url = FlashVars.attr('url');
            Config.name = FlashVars.attr('name', 'userfile');
            Config.types = FlashVars.attr('types', '*');
            Config.maxSize = FlashVars.attr('maxsize', Config.MAX_SIZE) * 1024 * 1024;
            
        }
        
        /**
         * 初始化界面
         */
        private function initUI():void 
        {
            // context menu
            var menu:ContextMenu = new ContextMenu();
            menu.hideBuiltInItems();
            menu.customItems.push(new ContextMenuItem(Config.CAPTION, false, false));
            contextMenu = menu;
            
            // create ui
            var tf:TextFormat = new TextFormat('vrinda', 12, 0x008000);

            selectBtn = new Button(skin.btnSelectUp, skin.btnSelectOver, skin.btnSelectDown, skin.btnSelectDisable, selectBtnHandler);
            cancelBtn = new Button(skin.btnCancelUp, skin.btnCancelOver, skin.btnCancelDown, skin.btnCancelDisable, cancelBtnHandler);
            progressBar = new ProgressBar(skin.progressFrontBar, skin.progressMaskBar, skin.progressMiddleBar, skin.progressBottomBar);

            txtPercent = new TextField();
            txtSpeed = new TextField();
            txtLeft = new TextField();

            tf.align = TextFormatAlign.LEFT;
            txtPercent.defaultTextFormat = tf;
            tf.align = TextFormatAlign.CENTER;
            txtSpeed.defaultTextFormat = tf;
            tf.align = TextFormatAlign.RIGHT;
            txtLeft.defaultTextFormat = tf;

            txtPercent.width = txtSpeed.width = txtLeft.width = TEXT_WIDTH;
            txtPercent.height = txtSpeed.height = txtLeft.height = TEXT_HEIGHT;
            txtPercent.selectable = txtSpeed.selectable = txtLeft.selectable = false;

            addChild(selectBtn);
            addChild(cancelBtn);
            addChild(progressBar);
            addChild(txtPercent);
            addChild(txtSpeed);
            addChild(txtLeft);
            
            resetButtons();
            
            resize();
        }
        
        /**
         * 重置按钮状态
         */
        private function resetButtons():void
        {
            cancelBtn.visible = false;
            selectBtn.enabled = true;
        }
        
        private function resize(evt:Event = null):void
        {
            selectBtn.x = cancelBtn.x = stage.stageWidth - selectBtn.width - PADDING;
            selectBtn.y = cancelBtn.y = Math.round((stage.stageHeight - selectBtn.height) / 2);

            progressBar.x = PADDING;
            progressBar.y = Math.round((stage.stageHeight - progressBar.height) / 2);
            progressBar.width = Math.round(stage.stageWidth - selectBtn.width - PADDING * 3);

            txtPercent.x = progressBar.x + SMALL_PADDING;
            txtSpeed.x = progressBar.x + (progressBar.width - TEXT_WIDTH) / 2;
            txtLeft.x = progressBar.x + progressBar.width - TEXT_WIDTH - SMALL_PADDING;

            txtPercent.y = txtSpeed.y = txtLeft.y = progressBar.y + (progressBar.height - TEXT_HEIGHT) / 2;
        }

        private function bindEvents():void
        {
            fileRef.addEventListener(Event.SELECT, selectHandler);
            fileRef.addEventListener(Event.OPEN, openHandler);
            fileRef.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            fileRef.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, completeHandler);
            fileRef.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
        }

        private function removeEvents():void
        {
            fileRef.removeEventListener(Event.SELECT, selectHandler);
            fileRef.removeEventListener(Event.OPEN, openHandler);
            fileRef.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
            fileRef.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, completeHandler);
            fileRef.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            resetButtons();
        }

        private function selectBtnHandler(evt:MouseEvent):void
        {
            bindEvents();
            fileRef.browse(types);
        }

        private function cancelBtnHandler(evt:MouseEvent):void
        {
            removeEvents();
            fileRef.cancel();
            JsProxy.call('onCancel', { id:Config.id } );
        }
        
        private function selectHandler(evt:Event):void 
        {
            if (checkFile(fileRef))
            {
                JsProxy.call('onStart', { id:Config.id, fileName:fileRef.name } );
                selectBtn.enabled = false;
                fileRef.upload(new URLRequest(Config.url), Config.name);
                _time = new Date().getTime();
            }
            else
            {
                removeEvents();
            }
        }
        
        private function checkFile(file:FileReference):Boolean 
        {
            if (!Config.url)
            {
                JsProxy.call('onError', { id:Config.id, message:'上传地址错误!' } );
            }
            if (file.size > Config.maxSize)
            {
                JsProxy.call('onError', { id: Config.id, message:Tool.formatString('文件不能超过 {0}Mbs.', Config.maxSize / 1024 / 1024) } );
                return false;
            }
            
            return true;
        }
        
        private function openHandler(evt:Event):void 
        {
            cancelBtn.visible = true;
            JsProxy.call('onOpen', { id:Config.id } );
        }

        private function progressHandler(evt:ProgressEvent):void
        {
            var speed:Number = Math.round(evt.bytesLoaded / (new Date().getTime() - _time) * 100) / 100;
            var per:Number = evt.bytesLoaded / evt.bytesTotal
            progressBar.percent = per;
            
            txtPercent.text = Tool.formatString('已上传: {0}%', Math.round(per * 100));
            txtSpeed.text = Tool.formatString('上传速度: {0} KB/s', speed);
            txtLeft.text = Tool.formatString('剩余: {0} 秒', Math.round((evt.bytesTotal - evt.bytesLoaded) / 1000 / speed));
        }
        
        private function completeHandler(evt:DataEvent):void 
        {
            JsProxy.call('onComplete', { id:Config.id, fileName:fileRef.name, data:evt.data } );
            removeEvents();
        }
        
        private function errorHandler(evt:IOErrorEvent):void 
        {
            JsProxy.call('onError', { id:Config.id, message:'上传失败!' } );
            removeEvents();
        }
        
        /**
         * 打开文件对话框文件类型过滤器
         */
        public function get types():Array 
        {
            if (!_types)
            {
                _types = [];
                var arrFilters:Array = Config.types.split(';');
                for (var i:int = 0, len:int = arrFilters.length; i < len; i++) 
                {
                    var filter:Array = arrFilters[i].split(':');
                    if (filter.length == 1)
                    {
                        if (filter[0] == '*')
                        {
                            filter[0] = 'All files';
                            filter.push('*.*');
                        }
                        filter.push(filter[0]);
                    }
                    var types:Array = filter[1].split(',');
                    _types.push(new FileFilter(filter[0], '*.' + types.join(';*.')));
                }
            }
            return _types;
        }
		
	}
	
}