package org.phpz.comm
{

    /**
     * 配置信息
     * @author Seven Yu
     */
    public class Config
    {

        // === 公共信息 ===
        CONFIG::debug
        {
            public static const IS_DEBUG:Boolean = true;
        }
        
        CONFIG::release
        {
            public static const IS_DEBUG:Boolean = false;
        }

        public static const NAME:String = 'Seven Uploader';
        public static const VERS_1:uint = 0; // 主版本号
        public static const VERS_2:uint = 0; // 里程碑版本号
        public static const VERS_3:uint = 1; // 编译版本号 保持奇数, 以区分 debug 版 (奇数) 和 release 版 (偶数)


        // === 上传配置 ===
        public static const MAX_SIZE:Number = 20; // 默认最大文件大小 (Mbs)

        
        // === 运行时变量 ===
        public static var id:String;
        public static var maxSize:uint = 0;
        public static var types:String; // 类型
        public static var name:String;
        public static var url:String;

        public static function get CAPTION():String
        {
            var vers:Array = [VERS_1, VERS_2, VERS_3 + (IS_DEBUG ? 0 : 1)];
            return NAME + ' ( version ' + vers.join('.') + ' )';
        }

    }

}