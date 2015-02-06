namespace Hsyngkby\Support\Environment;
use Closure;
class EnvironmentDetector {

    /**
     * Detect the application's current environment.
     *
     * @param  \Closure  $callback
     * @param  array|null  $consoleArgs
     * @return string
     */
    public function detect(callback, consoleArgs = null)
    {
        if consoleArgs
        {
            return this->detectConsoleEnvironment(callback, consoleArgs);
        }

        return this->detectWebEnvironment(callback);
    }

    /**
     * Set the application environment for a web request.
     *
     * @param  \Closure  $callback
     * @return string
     */
    protected function detectWebEnvironment(callback)
    {
        return call_user_func(callback);
    }

    /**
     * Set the application environment from command-line arguments.
     *
     * @param  \Closure  $callback
     * @param  array  $args
     * @return string
     */
    protected function detectConsoleEnvironment(callback, array args)
    {
        // First we will check if an environment argument was passed via console arguments
        // and if it was that automatically overrides as the environment. Otherwise, we
        // will check the environment as a "web" request like a typical HTTP request.
        var value;
        let value = this->getEnvironmentArgument(args);
        if !is_null(value)
        {
            return \Hsyngkby\Support\Helpers::head(array_slice(explode('=', value), 1));
        }

        return this->detectWebEnvironment(callback);
    }

    /**
     * Get the environment argument from the console.
     *
     * @param  array  $args
     * @return string|null
     */
    protected function getEnvironmentArgument(array args)
    {
        return array_first(args, function(k, v)
        {
            return starts_with(v, "--env");
        });
    }

}
