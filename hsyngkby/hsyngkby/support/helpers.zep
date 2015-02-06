namespace Hsyngkby\Support;

class Helpers{
    public static function env(key, _default = NULL)
    {
        var value;
        let value = getenv(key);

        if value === FALSE{
         return value(_default);
        }

        switch strtolower(value) {
            case "true":
            case "(true)":
                return TRUE;

            case "false":
            case "(false)":
                return FALSE;

            case "null":
            case "(null)":
                return NULL;

            case "empty":
            case "(empty)":
                return "";
        }

        return value;
    }

    /**
     * Get the first element of an array. Useful for method chaining.
     *
     * @param  array  $array
     * @return mixed
     */
    public static function head(array _array)
    {
        return reset(_array);
    }

    public static function __l()
    {
        var args;
        var log_levels;
        var log_level;
        var k,v,x;
        if self::env("APP_DEBUG"){
            return;
        }

        let args = func_get_args();

        let log_levels = [
            "debug"   : \Phalcon\Logger::DEBUG,
            "info"    : \Phalcon\Logger::INFO,
            "notice"  : \Phalcon\Logger::NOTICE,
            "warning" : \Phalcon\Logger::WARNING,
            "alert"   : \Phalcon\Logger::ALERT,
            "error"   : \Phalcon\Logger::ERROR
        ];

        let log_level = [
            "type"  : "log",
            "level" : \Phalcon\Logger::INFO
        ];

        for k,v in $log_levels {
            if in_array(k, array_map("strtolower", args)) {
                let log_level = [
                    "type"  : k,
                    "level" : v
                ];
            }
        }

        for x in args{
            if array_key_exists(strtolower(x), log_levels){
                return;
            }
            var msg = "";
            let msg = x;
            switch log_level["type"]{
                case "debug":
                    var_dump(msg);
                    break;
                case "info":
                    var_dump(msg);
                    break;
                case "notice":
                    var_dump(msg);
                    break;
                case "warning":
                    var_dump(msg);
                    break;
                case "alert":
                    var_dump(msg);
                    break;
                case "error":
                    var_dump(msg);
                    break;
            }
        };
    }
}