namespace Hsyngkby\Support;

use BadMethodCallException;

abstract class ServiceProvider
{
	/**
     * The application instance.
     *
     * @var \Hsyngkby\Support\Application
     */
    protected app;

    /**
     * Indicates if loading of the provider is deferred.
     *
     * @var bool
     */
    protected defer = false;

    /**
     * The paths that should be published.
     *
     * @var array
     */
    protected static publishes;

    /**
     * The paths that should be published by group.
     *
     * @var array
     */
    protected static publishGroups;

    /**
     * Create a new service provider instance.
     *
     * @param  \Hsyngkby\Support\Application  $app
     * @return void
     */
    public function __construct(app)
    {
        let this->app = app;
    }	
	/**
     * Register the service provider.
     *
     * @return void
     */
    abstract public function register();
    /**
     * Merge the given configuration with the existing configuration.
     *
     * @param  string  $path
     * @param  string  $key
     * @return void
     */
    protected function mergeConfigFrom(_path, _key)
    {
    	var _config;
        let _config = this->app["config"]->get(_key, []);

        this->app["config"]->set(_key, array_merge(require _path, _config));
    }

    /**
     * Register a view file namespace.
     *
     * @param  string  $path
     * @param  string  $namespace
     * @return void
     */
    protected function loadViewsFrom(_path, _namespace)
    {
    	var _appPath;
    	let _appPath = this->app->basePath()."/resources/views/vendor/"._namespace;
        if is_dir(_appPath)
        {
            this->app["view"]->addNamespace(_namespace, _appPath);
        }

        this->app["view"]->addNamespace(_namespace, _path);
    }

    /**
     * Register a translation file namespace.
     *
     * @param  string  $path
     * @param  string  $namespace
     * @return void
     */
    protected function loadTranslationsFrom(_path, _namespace)
    {
        this->app["translator"]->addNamespace(_namespace, _path);
    }

    /**
     * Register paths to be published by the publish command.
     *
     * @param  array  $paths
     * @param  string  $group
     * @return void
     */
    protected function publishes(array _paths, _group = null)
    {
    	var _class;
        let _class = get_class(this);

        if !array_key_exists(_class, self::publishes)
        {
            let self::publishes[_class] = [];
        }

        let self::publishes[_class] = array_merge(self::publishes[_class], _paths);

        if (_group)
        {
            let self::publishGroups[_group] = _paths;
        }
    }

    /**
     * Get the paths to publish.
     *
     * @param  string  $provider
     * @param  string  $group
     * @return array
     */
    public static function pathsToPublish(_provider = null, _group = null)
    {
    	var _paths;
    	var _class,_publish;

        if _group && array_key_exists(_group, self::publishGroups)
        {
            return self::publishGroups[_group];
        }

        if _provider && array_key_exists(_provider, self::publishes)
        {
            return self::$publishes[_provider];
        }

        let _paths = [];

        for _class , _publish in self::publishes
        {
            let _paths = array_merge(_paths, _publish);
        }

        return _paths;
    }

    /**
     * Register the package's custom Artisan commands.
     *
     * @param  array  $commands
     * @return void
     */
    public function commands(_commands)
    {
    	var _events;

        let _commands = is_array(_commands) ? _commands : func_get_args();

        // To register the commands with Artisan, we will grab each of the arguments
        // passed into the method and listen for Artisan "start" event which will
        // give us the Artisan console instance which we will give commands to.
        let _events = this->app["events"];

        /*
        _events->listen("artisan.start", function(_artisan) use (_commands)
        {
            _artisan->resolveCommands(_commands);
        });
		*/
    }

    /**
     * Get the services provided by the provider.
     *
     * @return array
     */
    public function provides()
    {
        return [];
    }

    /**
     * Get the events that trigger this service provider to register.
     *
     * @return array
     */
    public function when()
    {
        return [];
    }

    /**
     * Determine if the provider is deferred.
     *
     * @return bool
     */
    public function isDeferred()
    {
        return this->defer;
    }

    /**
     * Get a list of files that should be compiled for the package.
     *
     * @return array
     */
    public static function compiles()
    {
        return [];
    }

    /**
     * Dynamically handle missing method calls.
     *
     * @param  string  $method
     * @param  array  $parameters
     * @return mixed
     */
    public function __call(_method, _parameters)
    {
        if _method == "boot"{
        	return;
        } 

        throw new BadMethodCallException("Call to undefined method [{$method}]");
    }

}
