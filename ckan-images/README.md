# CKAN CI/CD Docker Images

## The Images

These images provide a couple of environments destined to be use in specific scenarios (Buildtime and Runtime) and where design to work together as part of the building process.

* CKAN Base:
  An Alpine based image with minimal runtime installation which includes: Python, minimal runtime packages, and the **start** script to launch the application service once installed.

* CKAN Build:
  Based in *CKAN Base* image, this one contains all required development and building packages and dependencies as well as a vanilla CKAN deployment installed in the virtual environment from the base image.
  It also contains a **build** script to be executed on its child images that will install CKAN extensions, CKAN Patches, and ini files customization settings.

* CKAN Client:
  This images gets created by simply injecting the resulting virtual environment folder from the *CKAN Build* image (after having run the build script) into the *CKAN Base* image.
  It only contains the necessary files and libraries for running the service in a runtime environment. No new images can (or should) be created from this one.


## Buildtime Images Build Process

1. Build the base image:
	1. Move to `ckan-base` folder
	2. Run the command:

		```sh
		docker build -t ckan-base:2.7-1.0.0 .
		```
1. Build the build image:
	1. Move to `ckan-build` folder
	2. Run the command:

		```sh
		docker build -t ckan-build:2.8.2-1.0.0 .
		```
		
## Runtime Image Build Process

1. Build the runtime image:
	1. Creates a Dockerfile following the example in `ckan-client-example` folder
	2. Run the command:

		```sh
		docker build -t ckan-client:1.0.0 .
		```

## Images Tag Naming Convention

### CKAN Base Image

The CKAN Base image uses a tag naming convention that shows the python version the environment has, and the image version it self to be able to introduce new changes in an image
that will be widely used.

**Tag Name Convention**:
`<python-version-minor>-<image-version>`

**where**:
 * *python-version-minor*: First two numbers of the python version (major and minor). i.e.: 2.7, 3.2
 * *image-version*: The specific image version for said python version, following [Semantic Versioning 2.0.0](https://semver.org) convention. i.e. 1.0.0, 3.2.6

	i.e.:
	`2.7-1.0.1`: It's the 1.0.0 version of the base image that provides Python 2.7.

### CKAN Build Image

The CKAN Build image uses a tag naming convention that shows the CKAN version the environment has, and the image version it self to be able to introduce new changes in an image
that will be widely used.

**Tag Name Convention**:
`<ckan-version->-<image-version>`

**where**:
* *ckan-version*: The CKAN version installed in the environment. i.e.: 2.8.2, 2.8.6, 2.9.0
* *image-version*: The specific image version for said python version, following [Semantic Versioning 2.0.0](https://semver.org) convention. i.e. 1.0.0, 3.2.6

	i.e.:
	`2.8.2-1.0.1`: It's the 1.0.0 version of the base image that provides CKAN 2.8.2.

## Create a new Client Image

By previously creating a Base image with the minimum runtime dependencies, and a Buildtime image with all the development requirements for compiling dependencies from their source files allow us now to be able to create a Runtime image with just the needed files and dependencies for executing the services and, at the same time, keep the Dockerfiles and repositories of each client image as clean and small as possible.

To create a new client image ready to run CKAN out of the box, simply create a Dockerfile as follows:
```Dockerfile
FROM ckan-build:2.8.2-1.0.0 as build
FROM ckan-base:2.7-1.0.0
COPY --from=build ${APP_DIR} ${APP_DIR}
```

**IMPORTANT**: Both FROM commands in this examples point to the images tags as created in section [ Buildtime Images Build Process](#buildtime-images-build-process), for real clients images creations you may want to use the images from the official registries.

This **Dockerfile** contains just 3 commands, but it does a lot more. By using `ONBUILD` commands, on the **build** image, we prepared the necessary steps to create client images before hand and they get executed right after the first `FROM` command in the Dockerfile. 

At this stage all the files ending with `_dx.txt` suffix will be copied into the working directory of the building image, and then the **build** script will use them to install extensions and patches into CKAN virtual environment.

Then a new build stage is created with the second `FROM`, and the virtual environment gets copied from the buildtime image. With this the client image is completed and ready to go.

### Folders Hierarchy

This is how a client image docker folder should be organized in order to work with the vase and build images. 

The **Dockerfile** is the only required file, but you can add the rest to customize the installation.

```
ckan-client-example
├── licenses.json
├── patches
│   ├── ckan
│   ├── ckanext-harvest
│   └── ...
├── Dockerfile
├── ini_dx.txt
├── plugins_dx.txt
└── requirements_dx.txt
```

### Customizing CKAN Installation

If you run the docker build command with just the **Dockefile** as described in the previous sections you would get a Vanilla CKAN installation ready to go, but if you require to install some extra extensions, patches, or add settings to the **production.ini** file, you don't need to modify the **Dockerfile** at all. 

The **build** script is prepared to go though the installation process of different elements (like extensions and patches) by using some reference files and folders described below:

* **requirements_dx.txt**: Contains a list of remote **requirements.txt** files and git repositories for installing the extensions.

  **i.e.**:
  If you require to install the `ckanext-authz-service` extension into your CKAN Client image, instead of adding the usual `pip install` lines to the **Dockerfile**:

   ```bash
   pip install --no-cache-dir -r https://raw.githubusercontent.com/datopian/ckanext-authz-service/master/requirements.py2.txt
   pip install -e git+https://github.com/datopian/ckanext-authz-service.git@v0.1.3#egg=ckanext-authz-service
   ```
   
   Just add those URLs into the **requirements_dx.txt**:
   ```txt
   https://raw.githubusercontent.com/datopian/ckanext-authz-service/master/requirements.py2.txt
   git+https://github.com/datopian/ckanext-authz-service.git@v0.1.3#egg=ckanext-authz-service
   ```
   
   The **build** script will process all the *requirements* files first and execute `pip install` for them, and then will do the same for the git repositories, making sure all the elements get installed in the correct paths and in the right order.

* **plugins_dx.txt**: Contains a space separated list of CKAN plugins names to be appended to the defaults.

  Right after completing all the extensions installation, the **build** script will execute the `paster` commands to recreate the production.ini file, and update the list of plugins:
  
  ```sh
  paster --plugin=ckan config-tool production.ini "ckan.plugins = <default_plugins_list> <custom_plugins_list>"
  ```
  
  **i.e.**:
  ```txt
  versioning authz-service
  ```

* **ini_dx.txt**: Contains a list of CKAN INI configuration settings to be added to the image `production.ini` file.

  The **build** script will finally append all the settings from the **ini_dx.txt** file to the **production.ini** file after having set the plugins list.

  **i.e.**:
  ```txt
  ckanext.versioning.backend_type = filesystem
  ckanext.versioning.backend_config = {"uri":"./metastore"}
  ```

* **patches**: A folder with the patches to be applied to CKAN core or any of the built extensions. 

  Create a sub-folder inside **patches** folder with the name of the package to patch (ie `ckan` or `ckanext-??`). 
  
  Inside you can place patch files that will be applied when building the images. The patches will be applied in alphabetical order, so you can prefix them sequentially if necessary. The patches will get processed right after the extensions are installed, and before recreating/updating the **production.ini** file.

  **i.e.**:
  
  Check the following example image folder:

  ```
  ckan-client-example
  ├── patches
  │   ├── ckan
  │   │   ├── 01_datasets_per_page.patch
  │   │   ├── 02_groups_per_page.patch
  │   │   ├── 03_or_filters.patch
  │   └── ckanext-harvest
  │       └── 01_resubmit_objects.patch
  ├── Dockerfile
  ...
  ```

* **licenses**: Any file named with *license* prefix will be included in CKAN image. 

  Create as many files following the naming convention *license*.json* in the root folder and they will be copied to */etc* path in the resulting image.

  **i.e.**:
  
  Check the following file names examples:
  * licenses.json
  * license-google.json
  * license-awesome.json

## Local Environment

1. Build the client image following the steps described above.
2. Download the [docker-ckan repository](https://github.com/okfn/docker-ckan/archive/master.zip).
3. Modify the **postgresql/Dockerfile** first line from `postgres:12-alpine` to `postgres:11-alpine`
4. And replace the **docker-compose.yml** with [this one](https://gist.github.com/santiago-teracloud/992d5299e9f5e627831346b929f991d4).
5. Launch the environment with this command:
   ```sh
   docker-compose up -d
   ```

   Check the logs with:
   ```sh
   docker-compose logs -f
   ```

6. Once every service is up and running, point your browser to http://localhost:5000 .