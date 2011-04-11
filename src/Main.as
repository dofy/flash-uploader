package
{
    import com.maccherone.json.JSON;
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

        private const SIZE_FULL:uint = 0;
        private const SIZE_BIG:uint = 450;
        private const SIZE_MID:uint = 360;
        private const SIZE_SML:uint = 210;

        private const NAME:String = 'Seven Uploader';
        private const VERS_1:uint = 1; // 主版本号
        private const VERS_2:uint = 1; // 里程碑版本号
        private const VERS_3:uint = 3; // 编译版本号 保持奇数, 以区分 debug 版 (奇数) 和 release 版 (偶数)

        private const MAX_SIZE:Number = 20; // 默认最大文件大小 (Mbs)


        private var upId:String;
        private var upURL:String;
        private var upName:String;
        private var upTypes:String;
        private var upMaxSize:uint;

        private var skin:DefaultSkin = new DefaultSkin();

        private var selectBtn:Button;
        private var cancelBtn:Button;
        private var progressBar:ProgressBar;

        private var txtPercent:TextField;
        private var txtSpeed:TextField;
        private var txtLeft:TextField;

        private var tf:TextFormat = new TextFormat('Verdana', 12, 0x008000);
        private var fileRef:FileReference = new FileReference();

        private var _sizeMode:uint = SIZE_FULL;

        private var _time:Number;

        private var _types:Array;

        private var _typeReg:RegExp;
        private var _exts:Array = [];


        public function Main():void
        {
            if (stage)
                init();
            else
                addEventListener(Event.ADDED_TO_STAGE, init);
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

            upId = FlashVars.attr('id');
            upURL = FlashVars.attr('url');
            upName = FlashVars.attr('name', 'userfile');
            upTypes = FlashVars.attr('types', '*');
            upMaxSize = FlashVars.attr('maxsize', MAX_SIZE) * 1024 * 1024;
        }

        /**
         * 初始化界面
         */
        private function initUI():void
        {
            // context menu
            var menu:ContextMenu = new ContextMenu();
            menu.hideBuiltInItems();
            menu.customItems.push(new ContextMenuItem(CAPTION, false, false));
            contextMenu = menu;

            // create ui
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

            addChild(progressBar);
            addChild(txtPercent);
            addChild(txtSpeed);
            addChild(txtLeft);

            addChild(selectBtn);
            addChild(cancelBtn);

            txtPercent.text = '请选择文件...';

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
            resetUI();

            if (stage.stageWidth >= SIZE_SML)
            {
                selectBtn.x = cancelBtn.x = stage.stageWidth - selectBtn.width - PADDING;
            }
            else
            {
                selectBtn.x = cancelBtn.x = 0;
            }
            selectBtn.y = cancelBtn.y = Math.round((stage.stageHeight - selectBtn.height) / 2);

            // 进度条 & 本分比
            if (stage.stageWidth >= SIZE_SML)
            {
                progressBar.x = PADDING;
                progressBar.y = Math.round((stage.stageHeight - progressBar.height) / 2);
                progressBar.width = Math.round(stage.stageWidth - selectBtn.width - PADDING * 3);
                txtPercent.x = progressBar.x + SMALL_PADDING;
            }

            // 剩余时间
            if (stage.stageWidth >= SIZE_BIG)
            {
                txtLeft.x = progressBar.x + progressBar.width - TEXT_WIDTH - SMALL_PADDING;
            }

            // 速度
            if (stage.stageWidth >= SIZE_BIG)
            {
                txtSpeed.x = progressBar.x + (progressBar.width - TEXT_WIDTH) / 2;
            }
            else if (stage.stageWidth >= SIZE_MID)
            {
                txtSpeed.x = progressBar.x + progressBar.width - TEXT_WIDTH - SMALL_PADDING;
            }

            txtPercent.y = txtSpeed.y = txtLeft.y = progressBar.y + (progressBar.height - TEXT_HEIGHT) / 2;
        }

        private function resetUI():void
        {
            if (stage.stageWidth < SIZE_SML)
            {
                if (_sizeMode != SIZE_SML)
                {
                    _sizeMode = SIZE_SML;
                    progressBar.visible = txtPercent.visible = txtSpeed.visible = txtLeft.visible = false;
                }
            }
            else if (stage.stageWidth < SIZE_MID)
            {
                if (_sizeMode != SIZE_MID)
                {
                    _sizeMode = SIZE_MID;
                    progressBar.visible = txtPercent.visible = true;
                    txtSpeed.visible = txtLeft.visible = false;
                }
            }
            else if (stage.stageWidth < SIZE_BIG)
            {
                if (_sizeMode != SIZE_BIG)
                {
                    _sizeMode = SIZE_BIG;
                    progressBar.visible = txtPercent.visible = txtSpeed.visible = true;
                    txtLeft.visible = false;

                    tf.align = TextFormatAlign.RIGHT;
                    txtSpeed.defaultTextFormat = tf;
                    txtSpeed.text = txtSpeed.text;
                }
            }
            else
            {
                if (_sizeMode != SIZE_FULL)
                {
                    _sizeMode = SIZE_FULL;
                    progressBar.visible = txtPercent.visible = txtSpeed.visible = txtLeft.visible = true;

                    tf.align = TextFormatAlign.CENTER;
                    txtSpeed.defaultTextFormat = tf;
                    txtSpeed.text = txtSpeed.text;
                }
            }
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

        /**
         * 浏览文件
         * @param	evt
         */
        private function selectBtnHandler(evt:MouseEvent):void
        {
            bindEvents();
            fileRef.browse(types);
        }

        /**
         * 取消上传
         * @param	evt
         */
        private function cancelBtnHandler(evt:MouseEvent):void
        {
            removeEvents();
            fileRef.cancel();
            JsProxy.call('onCancel', {id: upId, fileName: fileRef.name});
        }

        /**
         * 打开文件
         * @param	evt
         */
        private function selectHandler(evt:Event):void
        {
            if (checkFile(fileRef))
            {
                selectBtn.enabled = false;
                fileRef.upload(new URLRequest(upURL), upName);
                _time = new Date().getTime();
            }
            else
            {
                removeEvents();
            }
        }

        /**
         * 检测文件合法性
         * @param	file
         * @return
         */
        private function checkFile(file:FileReference):Boolean
        {
            if (!upURL)
            {
                JsProxy.call('onWarn', {id: upId, fileName: fileRef.name, message: '上传地址错误!'});
                return false;
            }
            var ext:String = Tool.getFileType(file, false);
            if (!typeReg.test(ext))
            {
                JsProxy.call('onWarn', {id: upId, fileName: fileRef.name, message: Tool.formatString('不被允许的文件类型: {0}', ext)});
                return false;
            }
            if (file.size > upMaxSize)
            {
                JsProxy.call('onWarn', {id: upId, fileName: fileRef.name, message: Tool.formatString('文件不能超过 {0}Mbs, 当前文件 {1}Mbs.', upMaxSize / 1024 / 1024, Math.round(file.size / 1024 / 1024 * 100) / 100)});
                return false;
            }

            return true;
        }

        /**
         * 开始上传
         * @param	evt
         */
        private function openHandler(evt:Event):void
        {
            cancelBtn.visible = true;
            JsProxy.call('onStart', {id: upId, fileName: fileRef.name});
        }

        /**
         * 上传进度
         * @param	evt
         */
        private function progressHandler(evt:ProgressEvent):void
        {
            var speed:Number = Math.round(evt.bytesLoaded / (new Date().getTime() - _time) * 100) / 100;
            var per:Number = evt.bytesLoaded / evt.bytesTotal
            progressBar.percent = per;

            txtPercent.text = Tool.formatString('已上传: {0}%', Math.round(per * 100));
            txtSpeed.text = Tool.formatString('上传速度: {0} KB/s', speed);
            txtLeft.text = Tool.formatString('剩余: {0} 秒', Math.round((evt.bytesTotal - evt.bytesLoaded) / 1000 / speed));
        }

        /**
         * 上传完成
         * @param	evt
         */
        private function completeHandler(evt:DataEvent):void
        {
            try
            {
                var json:Object = JSON.decode(evt.data);
                JsProxy.call('onComplete', {id: upId, fileName: fileRef.name, data: json});
            }
            catch (e:Error)
            {
                JsProxy.call('onWarn', {id: upId, fileName: fileRef.name, message: '服务器发生错误!'});
            }
            removeEvents();
        }

        /**
         * 上传地址错误
         * @param	evt
         */
        private function errorHandler(evt:IOErrorEvent):void
        {
            JsProxy.call('onWarn', {id: upId, fileName: fileRef.name, message: '上传失败!'});
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
                var arrFilters:Array = Tool.trim(upTypes, ';').split(';');
                for (var i:int = 0, len:int = arrFilters.length; i < len; i++)
                {
                    var filter:Array = arrFilters[i].split(':');
                    if (filter.length == 1)
                    {
                        if (filter[0] == '*')
                        {
                            filter[0] = 'All files';
                            filter.push('*');
                        }
                        else
                        {
                            filter.push(filter[0]);
                        }
                    }
                    var types:Array = filter[1].replace(/\s/g, '').split(',');
                    _types.push(new FileFilter(filter[0], '*.' + types.join(';*.')));
                    _exts = _exts.concat(types);
                }
            }
            return _types;
        }

        /**
         * 匹配扩展名的正则
         */
        private function get typeReg():RegExp
        {
            if (!_typeReg)
            {
                if (_exts.indexOf('*') != -1)
                {
                    _typeReg = /.*/;
                }
                else
                {
                    _typeReg = new RegExp(_exts.join('|'), 'i');
                }
            }
            return _typeReg;
        }

        /**
         * 版本信息
         */
        private function get CAPTION():String
        {
            var vers:Array = [VERS_1, VERS_2, VERS_3];

            CONFIG::release
            {
                vers[2]++;
            }

            return NAME + ' ( version ' + vers.join('.') + ' )';
        }

    }

}