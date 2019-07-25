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

      order: 1
    theme:
      title: 'Theme'
      type: 'string'
      default: 'bootstrap2'
      enum: ['bootstrap2', 'bootstrap3', 'bootstrap4', 'foundation', 'foundation3', 'foundation4', 'foundation5', 'foundation6', 'html', 'jqueryui', 'barebones', 'materialize']
      description: 'Theme used for JSONEditor'
      order: 2
    iconlib:
      title: 'Icons Library'
      type: 'string'
      default: 'bootstrap2'
      enum: ['bootstrap2', 'bootstrap3', 'fontawesome3', 'fontawesome4', 'foundation2', 'foundation3', 'jqueryui', 'materialicons']
      description: 'Icons library used for JSONEditor'
      order: 3
    template:
      title: 'Template'
      type: 'string'
      default: 'default'
      enum: ['default', 'ejs', 'handlebars', 'hogan', 'lodash', 'markup', 'mustache', 'swig', 'underscore']
      description: 'Template used for JSONEditor'
      order: 4
    object_layout:
      title: 'Layout'
      type: 'string'
      default: 'normal'
      enum: ['normal', 'grid']
      description: 'Layout used for JSONEditor'
      order: 5
    show_errors:
      title: 'Show Errors'
      type: 'string'
      default: 'always'
      enum: ['always','never','change','interaction']
      description: 'When to show errors'
      order: 6
    prompt_before_delete:
      description: 'Prompt before delete'
      type: 'boolean'
      default: true
      order: 7
    no_additional_properties:
      description: 'No additional properties'
      type: 'boolean'
      default: false
      order: 8
    display_required_only:
      description: 'Only show required properties by default'
      type: 'boolean'
      default: false
      order: 9
    collapsed:
      description: 'Start collapsed'
      type: 'boolean'
      default: true
      order: 10
    disable_collapse:
      description: 'Disable `Collapse` buttons'
      type: 'boolean'
      default: false
      order: 11
    disable_edit_json:
      description: 'Disable `Edit JSON` buttons'
      type: 'boolean'
      default: false
      order: 12
    remove_empty_properties:
      description: 'Remove empty properties'
      type: 'boolean'
      default: true
      order: 13
    disable_properties:
      description: 'Disable `Properties` buttons'
      type: 'boolean'
      default: false
      order: 14
    required_by_default:
      description: 'Object properties required by default'
      type: 'boolean'
      default: false
      order: 15
    disable_array_delete:
      description: 'Disable array `Delete` buttons'
      type: 'boolean'
      default: false
      order: 16
    disable_array_delete_all_rows:
      description: 'Disable array `Delete all rows` buttons'
      type: 'boolean'
      default: false
      order: 17
    disable_array_delete_last_row:
      description: 'Disable array `Delete last row` buttons'
      type: 'boolean'
      default: false
      order: 18
    disable_array_reorder:
      description: 'Disable array `Move` buttons'
      type: 'boolean'
      default: false
      order: 19
    disable_array_add:
      description: 'Disable array `Add` buttons'
      type: 'boolean'
      default: false
      order: 20
    enable_array_copy:
      description: 'Add `Copy` buttons to arrays'
      type: 'boolean'
      default: false
      order: 21
    array_controls_top:
      description: 'Array controls will be displayed at top of list'
      type: 'boolean'
      default: true
      order: 22
    keep_oneof_values:
      description: 'Keep oneof values'
      type: 'boolean'
      default: false
      order: 23
    ajax:
      description: 'Load external $ref'
      type: 'boolean'
      default: false
      order: 24
    compact:
      description: 'Hide labels'
      type: 'boolean'
      default: true
      order: 25

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
      regex = /([\-\_a-z0-9]*).json$/i
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
          atom.notifications.addError "Schema at #{path} contains invalid JSON",
            detail: error
    else
      # Failed with the given path, try with fallback if set
      @startForSchemaAtPath fallback if fallback?

  save: ->
    try
      editor = atom.workspace.getActiveTextEditor()
      value = @editor.getValue()

      indent = if editor.getSoftTabs() then ' '.repeat editor.getTabLength() else '\t'
      editor.setText JSON.stringify value, null, indent
      editor.save()
    catch error
      atom.notifications.addWarning 'Error on saving',
        detail: error

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
      theme: atom.config.get 'atom-json-editor.theme' # "barebones" 
      iconlib: atom.config.get 'atom-json-editor.iconlib' # "jqueryui" 
      object_layout: atom.config.get 'atom-json-editor.object_layout' # "grid"
      show_errors: atom.config.get 'atom-json-editor.show_errors' # "always"
      template: atom.config.get 'atom-json-editor.template'
      required_by_default: atom.config.get 'atom-json-editor.required_by_default' # Object properties required by default
      display_required_only: atom.config.get 'atom-json-editor.display_required_only' # Only show required properties by default
      no_additional_properties: atom.config.get 'atom-json-editor.no_additional_properties' # No additional object properties
      ajax: atom.config.get 'atom-json-editor.ajax' # Allow loading schemas via Ajax
      disable_edit_json: atom.config.get 'atom-json-editor.disable_edit_json' # Disable "Edit JSON" buttons
      disable_collapse: atom.config.get 'atom-json-editor.disable_collapse' # Disable collapse buttons
      disable_properties: atom.config.get 'atom-json-editor.disable_properties' # Disable properties buttons
      disable_array_add: atom.config.get 'atom-json-editor.disable_array_add' # Disable array add buttons
      disable_array_reorder: atom.config.get 'atom-json-editor.disable_array_reorder' # Disable array move buttons
      disable_array_delete: atom.config.get 'atom-json-editor.disable_array_delete' # Disable array delete buttons
      enable_array_copy: atom.config.get 'atom-json-editor.enable_array_copy' # Add copy buttons to arrays
      array_controls_top: atom.config.get 'atom-json-editor.array_controls_top' # Array controls will be displayed at top of list
      disable_array_delete_all_rows: atom.config.get 'atom-json-editor.disable_array_delete_all_rows' # Disable array delete all rows buttons
      disable_array_delete_last_row: atom.config.get 'atom-json-editor.disable_array_delete_last_row' # Disable array delete last row buttons
      remove_empty_properties: atom.config.get 'atom-json-editor.remove_empty_properties'
      compact: atom.config.get 'atom-json-editor.compact'
      schema: schema
      startval: startval

    @editor.on 'change', () => @save()

    @modalPanel.show()

  end: ->
    @modalPanel.hide()
    @editor?.destroy()
