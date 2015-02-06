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
}