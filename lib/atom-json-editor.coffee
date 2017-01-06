AtomJsonEditorView = require './atom-json-editor-view'
JSONEditor = require './deps/jsoneditor.min.js'
{CompositeDisposable, File, Directory} = require 'atom'
ApiPath = require 'path'

# Constants
defaultSchemesDir = 'Package Schemes'

module.exports = AtomJsonEditor =
  config:
    schemesDir:
      title: 'Schemes Directory'
      type: 'string'
      description: 'Path to a directory containing JSON schemes'
      default: defaultSchemesDir


  atomJsonEditorView: null
  modalPanel: null
  editor: null

  activate: (state) ->
    @atomJsonEditorView = new AtomJsonEditorView(state.atomJsonEditorViewState)
    @modalPanel = atom.workspace.addRightPanel(item: @atomJsonEditorView.getElement(), visible: false)

    # check active file now and on any new opened file
    @checkActiveFile();
    atom.workspace.onDidChangeActivePaneItem () => @checkActiveFile()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomJsonEditorView.destroy()

  serialize: ->
    atomJsonEditorViewState: @atomJsonEditorView.serialize()

  toggle: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
      @save()
      @end()
    else
      @modalPanel.show()
      @start()

  # Editor methods
  checkActiveFile: ->
    @end()

    try
      path = atom.workspace.getActiveTextEditor().getPath()
      regex = /([a-z0-9]*).json$/i
      match = regex.exec path

      if match?
        @startForSchemaWithName ApiPath.dirname(path), match[1]
    catch error
      # Could not get filepath.
      # Probably Settings is open

  startForSchemaWithName: (path, name) ->
    schemaFilename = name + '.schema.json'
    packageSchemaPath = __dirname + '/schemes/' + schemaFilename
    localSchemaPath = ApiPath.join(path, schemaFilename)

    localSchema = new File localSchemaPath
    if localSchema.existsSync()
      @startForSchemaAtPath localSchemaPath
    else
      dir = atom.config.get 'atom-json-editor.schemesDir'
      if dir == defaultSchemesDir
        # Try in package scheme dir
        @startForSchemaAtPath packageSchemaPath
      else # Check if directory specified in config exists
        directory = new Directory dir
        if directory.existsSync()
          # Try in config dir
          @startForSchemaAtPath dir + '/' + schemaFilename, packageSchemaPath
        else
          atom.notifications.addError dir + 'does not exist',
            detail: 'Invalid schemes directory'

  startForSchemaAtPath: (path, fallback) ->
    file = new File path

    if file.existsSync()
      (file.read true).then (schemaString) =>
        try
          @start JSON.parse schemaString
        catch error
          atom.notifications.addError schemeName + ' is no valid JSON',
            detail: error
    else
      # Failed with the given path, try with fallback if set
      @startForSchemaAtPath fallback if fallback?

  save: ->
    editor = atom.workspace.getActiveTextEditor()
    value = @editor.getValue()
    editor.setText JSON.stringify value, null, '\t'
    editor.save()

  start: (schema) ->
    text = atom.workspace.getActiveTextEditor().getText()
    startval = null

    if text
      try
        startval = JSON.parse text
      catch error
        atom.notifications.addWarning 'File contains no valid JSON. Initilized with empty object value',
          detail: error


    @editor = new JSONEditor @atomJsonEditorView.editorContainer,
      theme: 'bootstrap3'
      iconlib: 'bootstrap3'
      disable_edit_json: true
#      disable_properties: true
      remove_empty_properties: true
#      no_additional_properties: true
      show_errors: "always"
      schema: schema
      startval: startval

    @editor.on 'change', () => @save()

    @modalPanel.show()

  end: ->
    @modalPanel.hide()
    @editor?.destroy()
