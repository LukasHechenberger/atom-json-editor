# atom-json-editor package

Creates UI for json files created along their schemes.

**Based on [JSONEditor by Jeremy Dorn](https://github.com/jdorn/json-editor)**

![A screenshot of atom-json-editor](https://raw.githubusercontent.com/LukasHechenberger/atom-json-editor/master/screenshot.png)

## Usage

atom-json-editor tries to build a UI for a file every time you switch to a tab containing a `.json` file. The resulting `JSON` data is automatically saved on change.

## Adding custom schemes

By default, some basic schemes are included with the package. Add your own schemes to build `.json` files in your own format

### Schemes are picked by name conversion

Any scheme should have the file extension `.schema.json`. Any `.json` file containing it's filename is validated against it. 

As an example `package.json` is validated against `package.schema.json`. As would `any-prefix.package.json`.

### Using Schemes in your Working Directory
> Available since 0.4.0, with thanks to [DimShadoWWW](https://github.com/DimShadoWWW)

First of all, atom-json-editor will check if there is a valid `.schema.json`-File inside your current working directory. This means that a File inside `~/anywhere/file.json` will be validated against `~/anywhere/file.schema.json` if available.

If no valid schema is found inside your working directory, atom-json-editor will continue searching in your *Schemes Directory*.

### Using your own Schemes Directory

Within the package settings choose atom-json-editor. The only option available by now is *Schemes Directory*. Set it to an (absolute) path where your schemes are stored.

If a scheme isn't found in your Schemes Directory, atom-json-editor will try to get one from it's package library.

### Adding schemes to the package library *(deprecated)*

You can also add schemes directly to the package library by moving them into `~/.atom/packages/atom-json-editor/lib/schemes/`.

**Note that schemes added to the package library may be replaced when updating this package.**

## Known issues

### A JSON file is open while installing the package

If a `JSON` file is open while installing the package, you have to de- and reselect the file's tab to start the editor.