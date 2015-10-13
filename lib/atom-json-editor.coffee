AtomJsonEditorView = require './atom-json-editor-view'
JSONEditor = require './deps/jsoneditor.min.js'
{CompositeDisposable, File} = require 'atom'

module.exports = AtomJsonEditor =
  atomJsonEditorView: null
  modalPanel: null
  subscriptions: null
  editor: null

  activate: (state) ->
    @atomJsonEditorView = new AtomJsonEditorView(state.atomJsonEditorViewState)
    @modalPanel = atom.workspace.addRightPanel(item: @atomJsonEditorView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-json-editor:toggle': => @toggle()

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
        @startForSchemaWithName match[1]
    catch error
      console.warn 'Could not get current file path '

  startForSchemaWithName: (name) ->
    file = new File '/Users/lukas/.atom/packages/atom-json-editor/lib/schemes/' + name + '.schema.json'

    if file.existsSync()
      (file.read true).then (schemaString) =>
        try
          @start JSON.parse schemaString
        catch error
          console.warn name + '.schema.json contains no valid JSON', error

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
        console.warn 'text is no valid JSON'


    @editor = new JSONEditor @atomJsonEditorView.editorContainer,
      theme: 'bootstrap2'
      iconlib: 'bootstrap2'
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
