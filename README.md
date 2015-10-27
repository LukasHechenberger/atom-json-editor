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

As an example `package.json` is validated against `package.scheme.json`. As would `any-prefix.package.json`.

### Using your own Schemes Directory

Within the package settings choose atom-json-editor. The only option available by now is *Schemes Directory*. Set it to an (absolute) path where your schemes are stored.

If a scheme isn't found in your Schemes Directory, atom-json-editor will try to get one from it's package library.

### Adding schemes to the package libarary *(deprecated)*

You can also add schemes directly to the package library by moving them into `~/.atom/packages/atom-json-editor/lib/schemes/`.

**Note that schemes added to the package library may be replaced when updating this package.**
