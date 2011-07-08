package org.phpz.utils
{
    import flash.external.ExternalInterface;
    import flash.net.FileReference;
    import flash.system.Capabilities;

    /**
     * ...
     * @author Seven Yu
     */
    public class Tool
    {

        /**
         * 获取文件扩展名
         * @param	file      文件
         * @param	withDot   是否包含点
         * @return  文件扩展名
         */
        public static function getFileType(file:FileReference, withDot:Boolean = true):String
        {
            if (file.type && file.type != "")
            {
                return (withDot ? file.type : file.type.substr(1)).toLowerCase();
            }
            else
            {
                return (withDot ? '.' : '') + file.name.split('.').pop().toLowerCase();
            }
        }

        /**
         * 获取文件名
         * @param	file      文件
         * @param	withExt   是否包含扩展名
         * @return  文件名
         */
        public static function getFileName(file:FileReference, withExt:Boolean = false):String
        {
            if (withExt)
            {
                return file.name;
            }
            else
            {
                return file.name.substring(0, file.name.lastIndexOf('.'));
            }
        }

        /**
         * 读取 Cookie
         * @param	key           键名
         * @param	defaultValue  默认值
         * @return  返回对应 Coolie 值或传入的默认值
         */
        public static function getCookie(key:String, defaultValue:String = null):String
        {
            if (ExternalInterface.available)
            {
                try
                {
                    var cookie:String = ExternalInterface.call('function (){ return document.cookie; }');
                    var items:Array = cookie.split(';');
                    var len:int = items.length;
                    for (var i:int = 0; i < len; i++)
                    {
                        var item:String = Tool.trim(items[i]);
                        if (0 == item.indexOf(key + '='))
                        {
                            return decodeURIComponent(item.split('=').pop());
                            break;
                        }
                    }
                }
                catch (e:Error)
                {
                    trace(e);
                }
            }
            return defaultValue;
        }

        /**
         * 添加参数到地址
         * @param	url
         * @param	params
         * @return
         */
        public static function addParams(url:String, params:Object):String
        {
            var paramArray:Array = [];
            for (var key:String in params)
            {
                paramArray.push(key + '=' + encodeURIComponent(params[key]));
            }
            if (!(/^https?:\/\//i.test(url)))
            {
                url = 'http://' + url;
            }
            return url + (url.indexOf('?') === -1 ? '?' : '&') + paramArray.join('&');
        }
        
        /**
         * 遍历处理数组
         * @param	array    要处理的数组
         * @param	handler  处理函数
         */
        public static function walkArray(array:Array, handler:Function):void
        {
            for (var i:int = 0, len:int = array.length; i < len; i++) 
            {
                handler(i, array[i]);
            }
        }

        /**
         * trim
         * @param	string
         * @return
         */
        public static function trim(string:String, search:String = '\\s'):String
        {
            var reg:RegExp = new RegExp('^' + search + '+|' + search + '+$', 'g');
            if (string)
            {
                return string.replace(reg, '');
            }
            else
            {
                return '';
            }
        }
        
        /**
         * 格式化字符串
         * formatString('This {0} a {1}.', 'is', 'test');
         * // return This is a rest.
         * @param	format     格式
         * @param	... items  替换项
         * @return  格式化后的字符串
         */
        public static function formatString(format:String, ... items):String
        {
            var reg:RegExp;
            for (var i:int = 0, len:int = items.length; i < len; i++) 
            {
                format = format.replace(new RegExp('\\{' + i + '\\}', 'g'), items[i]);
            }
            return format;
        }

        /**
         * 检测用户 Flash Player 版本号是否符合要求
         * @param	... vers 由大到小各版本号
         * @return  是否符合 (true or false)
         */
        public static function rightVersion(... vers):Boolean
        {
            var verInfo:Array = Capabilities.version.split(' ');
            var system:String = verInfo[0];
            var userVer:Array = verInfo[1].split(','); // 用户 Player 版本号

            for (var i:int = 0, pLen:int = userVer.length, cLen:int = vers.length; i < pLen && i < cLen; i++)
            {
                var u:int = Math.floor(userVer[i]); // 用户对应版本号
                var c:int = (/^[0-9]+$/.test(vers[i])) ? Math.floor(vers[i]) : 9999999;    // 检测对应版本号
                if (u > c)
                {
                    return true;
                }
                else if (u < c)
                {
                    return false;
                }
            }
            return true;
        }

    }

}