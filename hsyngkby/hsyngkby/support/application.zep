    namespace Hsyngkby\Support;

    use Hsyngkby\Support\Environment\EnvironmentDetector;
    use Hsyngkby\Support\Helpers;

    class Application extends \Phalcon\DI\FactoryDefault
    {
    protected booted = false {
        set, get
    };
    protected hasBeenBootstrapped = false {
        set, get
    };
    protected environmentFile = ".env" {
        set, get
    };
    protected variables = [] {
        set, get
    };
    protected serviceProviders = [] {
        set, get
    };
    protected loadedProviders = [] {
        set, get
    };
    protected deferredServices = [] {
        set, get
    };
    protected bootingCallbacks = [] {
        set, get
    };
    protected bootedCallbacks = [] {
        set, get
    };
    protected instence = [] {
        set, get
    };

    public function __construct()
    {
        parent::__construct();
    }
    //Boot Edilmişmi
    public function hasBeenBootstrapped()
    {
        return this->hasBeenBootstrapped;
    }
    //Bootstrap dosyalarını çalıştır.

    public function bootstrapWith(array bootstrappers)
    {
        var bootstrapper;
        for bootstrapper in bootstrappers {
            Helpers::__l("make ".bootstrapper."<br>");
            this->make(bootstrapper)->bootstrap(this);
        }
        let this->hasBeenBootstrapped = true;
    }
    /**
     * Resolve the given type from the container.
     *
     * (Overriding Container::make)
     *
     * @param  string  _abstract
     * @param  array   $parameters
     * @return mixed
     */
    public function make(_abstract, parameters = [])
    {
        if isset this->instence[_abstract]
        {
            return this->instence[_abstract];
        }

        if isset this->deferredServices[_abstract]
        {
            let this->instence[_abstract] = this->loadDeferredProvider(_abstract);
        }

        let this->instence[_abstract] = parent::get(_abstract, parameters);

        return this->instence[_abstract];
    }
    /**
     * Load the provider for a deferred service.
     *
     * @param  string  $service
     * @return void
     */
    public function loadDeferredProvider(service)
    {
        if isset this->deferredServices[service]
        {
            var provider;
            let provider = this->deferredServices[service];

            if isset this->loadedProviders[provider]
            {
                //load edilmişse bişi yapma
            }else{
                return this->registerDeferredProvider(provider, service);
            }
        }else{
            return;
        }
    }
    /**
     * Register a deferred provider and service.
     *
     * @param  string  $provider
     * @param  string  $service
     * @return void
     */
    public function registerDeferredProvider(provider, service = null)
    {
        var instance;

        // Once the provider that provides the deferred service has been registered we
        // will remove it from our local list of the deferred services with related
        // providers so that this container does not try to resolve it out again.
        if service==null {
            unset( this->deferredServices[service] );
        }

        let instance = new {provider}(this);
        this->register(instance);

        if this->booted
        {
            //Boot Edilmişse Bişi yapma
        }else{
            this->bootProvider(instance);
        }

        return instance;
    }
    /**
     * Register a new boot listener.
     *
     * @param  mixed  $callback
     * @return void
     */
    public function booting(callback)
    {
        let this->bootingCallbacks[] = callback;
    }
    /**
     * Boot the given service provider.
     *
     * @param  \Illuminate\Support\ServiceProvider $provider
     *
     * @return void
     */
    protected function bootProvider(provider)
    {
        if method_exists(provider, "boot") {
            return this->call([provider, "boot"]);
        }
    }
    /**
     * Call the given Closure / class@method and inject its dependencies.
     *
     * @param  callable|string $callback
     * @param  array           $parameters
     * @param  string|null     $defaultMethod
     *
     * @return mixed
     */
    public function call(callback, array parameters = [], defaultMethod = NULL)
    {
        var dependencies;

        if (this->isCallableWithAtSign(callback) || defaultMethod) {
            return this->callClass(callback, parameters, defaultMethod);
        }
        let dependencies = this->getMethodDependencies(callback, parameters);
        return call_user_func_array(callback, dependencies);
    }
    /**
     * Determine if the given string is in Class@method syntax.
     *
     * @param  mixed $callback
     *
     * @return bool
     */
    protected function isCallableWithAtSign(callback)
    {
        if !is_string(callback) {
            return FALSE;
        }

        return strpos(callback, '@') !== FALSE;
    }
    /**
     * Call a string reference to a class using Class@method syntax.
     *
     * @param  string      $target
     * @param  array       $parameters
     * @param  string|null $defaultMethod
     *
     * @return mixed
     * @throws \InvalidArgumentException
     */
    protected function callClass(target, array parameters = [], defaultMethod = NULL)
    {
        var segments;
        var method;

        let segments = explode('@', target);

        // If the listener has an @ sign, we will assume it is being used to delimit
        // the class name from the handle method name. This allows for handlers
        // to run multiple handler methods in a single class for convenience.
        let method = count(segments) == 2 ? segments[1] : defaultMethod;

        if (is_null(method)) {
            throw new \InvalidArgumentException("Method not provided.");
        }

        return this->call([this->make(segments[0]), method], parameters);
    }
    /**
     * Get all dependencies for a given method.
     *
     * @param  callable|string  $callback
     * @param  array  $parameters
     * @return array
     */
    protected function getMethodDependencies(callback, parameters = [])
    {
        var dependencies = [];
        var parameter;

        for parameter in this->getCallReflector(callback)->getParameters()
        {
            this->addDependencyForCallParameter(parameter, parameters, dependencies);
        }

        return array_merge(dependencies, parameters);
    }

    /**
     * Get the proper reflection instance for the given callback.
     *
     * @param  callable|string  $callback
     * @return \ReflectionFunctionAbstract
     */
    protected function getCallReflector(callback)
    {
        if (is_string(callback) && strpos(callback, '::') !== false)
        {
            let callback = explode('::', callback);
        }

        if is_array(callback)
        {
            return new \ReflectionMethod(callback[0], callback[1]);
        }

        return new \ReflectionFunction(callback);
    }
    /**
     * Get the dependency for the given call parameter.
     *
     * @param  \ReflectionParameter  $parameter
     * @param  array  $parameters
     * @param  array  $dependencies
     * @return mixed
     */
    protected function addDependencyForCallParameter(parameter, array parameters, dependencies)
    {
        if array_key_exists(parameter->name, parameters)
        {
            let dependencies[] = parameters[parameter->name];

            unset(parameters[parameter->name]);
        }
        elseif (parameter->getClass())
        {
            let dependencies[] = this->make(parameter->getClass()->name);
        }
        elseif (parameter->isDefaultValueAvailable())
        {
            let dependencies[] = parameter->getDefaultValue();
        }
    }

    /**
     * Get the registered service provider instance if it exists.
     *
     * @param  \Illuminate\Support\ServiceProvider|string $provider
     *
     * @return \Illuminate\Support\ServiceProvider|null
     */
    public function getProvider(provider)
    {
        var name;
        let name = is_string(provider) ? provider : get_class(provider);

        return array_first(this->serviceProviders, function (key, value) {
            return value instanceof name;
        });
    }

    /**
     * Resolve a service provider instance from the class name.
     *
     * @param  string $provider
     *
     * @return \Illuminate\Support\ServiceProvider
     */
    public function resolveProviderClass(provider)
    {
        return new {provider}(this);
    }

    /**
     * Mark the given provider as registered.
     *
     * @param  \Illuminate\Support\ServiceProvider
     *
     * @return void
     */
    protected function markAsRegistered(provider)
    {
        var _class;
        let _class = get_class(provider);
        let this->serviceProviders[] = provider;
        let this->loadedProviders[ _class ] = true;
    }




    /**
     * Register a service provider with the application.
     *
     * @param  \Illuminate\Support\ServiceProvider|string $provider
     * @param  array                                      $options
     * @param  bool                                       $force
     *
     * @return \Illuminate\Support\ServiceProvider
    */
    public function register(provider, options = [], force = FALSE)
    {
        var registered;
        var key,value;

        let registered = this->getProvider(provider);
        if  registered && !force{
            return registered;
        }

        // If the given "provider" is a string, we will resolve it, passing in the
        // application instance automatically for the developer. This is simply
        // a more convenient way of specifying your service provider classes.
        if is_string(provider) {
            let provider = this->resolveProviderClass(provider);
        }

        provider->register();

        // Once we have registered the service we will iterate through the options
        // and set each of them on the application so they will be available on
        // the actual loading of the service objects and for developer usage.
        for  key, value in options {
            this->setVariable(key,value);
        }

        this->markAsRegistered(provider);

        // If the application has already booted, we will call this boot method on
        // the provider class so it has an opportunity to do its boot logic and
        // will be ready for any usage by the developer's application logics.
        if (this->booted) {
            this->bootProvider(provider);
        }

    return provider;
    }




    public function environmentFile()
    {
        return this->environmentFile ? false : ".env";
    }

    public function environment()
    {
        var patterns;
        var pattern;
        if func_num_args() > 0 {
            let patterns = is_array(func_get_arg(0)) ? func_get_arg(0) : func_get_args();
            for pattern in $patterns {
                if str_is(pattern, this->getVariable("env")) {
                    return true;
                }
            }
            return false;
        }
        return this->getVariable("env");
    }

    public function detectEnvironment(callback)
    {
        var args;
        var env;

        let args = isset(_SERVER["argv"]) ? _SERVER["argv"] : null;
        let env = (new EnvironmentDetector())->detect(callback, args);
        this->setVariable("env",env);
        return this->getVariable("env");
    }

    public function bindPathsInContainer()
    {
        var path;
        var _func;
        var _def;
        var _path;
        for path in ["base", "app", "bootstrap", "config", "database", "public", "resource", "storage"] {
            let _func = path . "Path";
            let _path = this->{_func}();
            this->setVariable("path." . path , _path );
            let _def = strtoupper(path . "_path");
            if !defined(_def){
                define(_def, _path, false);
            }
        }
    }
    public function basePath()
    {
        return this->getVariable("path");
    }

    public function appPath()
    {
        return this->getVariable("path.base") . DIRECTORY_SEPARATOR . env("APP_PATH", "app");
    }

    public function bootstrapPath()
    {
        return this->getVariable("path.base") . DIRECTORY_SEPARATOR . env("BOOTSTRAP_PATH", "bootstrap");
    }

    public function configPath()
    {
        return this->getVariable("path.base") . DIRECTORY_SEPARATOR . env("CONFIG_PATH", "config");
    }

    public function databasePath()
    {
        return this->getVariable("path.base") . DIRECTORY_SEPARATOR . env("DATABASE_PATH", "database");
    }

    public function publicPath()
    {
        return this->getVariable("path.base") . DIRECTORY_SEPARATOR . env("PUBLIC_PATH", "public");
    }

    public function resourcePath()
    {
        return this->getVariable("path.base") . DIRECTORY_SEPARATOR . env("RESOURCE_PATH", "resource");
    }

    public function storagePath()
    {
    return this->getVariable("path.base") . DIRECTORY_SEPARATOR . env("STORAGE_PATH", "storage");
    }


    public function instance(_abstract, instance)
    {
        var _alias;

        if is_array(_abstract) {

            for _abstract,_alias in this->extractAlias(_abstract){}

            this->setVariable(("aliases." . _abstract) , _alias);
        }
        if !this->has(_abstract){
            this->attempt(_abstract, instance);
        }else{
            throw new \InvalidArgumentException(_abstract . " is instance already");
        }

    }
    protected function extractAlias(array definition)
    {
        return [key(definition), current(definition)];
    }
    public function attempt(name, definition, shared=null){
        parent::attempt(name, definition, shared);
    }
    /**
     * Resolves the service based on its configuration
     *
     * @param string name
     * @param array parameters
     * @return mixed
     */
    public function get(name, parameters=null){
        return parent::get(name, parameters);
    }

    /**
     * Register all of the configured providers.
     *
     * @return void
     */
    public function registerConfiguredProviders()
    {
        var manifestPath;
        var _config;
        let manifestPath = this->storagePath() . "/framework/services.json";
        let _config = this->get("config");
        let _config = _config->get("app.providers");
        (new ProviderRepository(this, new Filesystem, manifestPath))
            ->load(_config);
    }




    /**
    Setter Getter
    */
    public function getVariable(name){
        return this->variables[name];
    }
    public function setVariable(name,value){
        let this->variables[name] = value;
    }

    //Ofset
    public function offsetGet(name)
    {
        return this->getVariable(name);
    }

    public function offsetSet(name, definition)
    {
        return this->setVariable(name, definition);
    }
    }