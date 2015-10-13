module.exports =
class AtomJsonEditorView
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement 'div'
    @element.classList.add 'atom-json-editor'

    # Create editor container
    @editorContainer = document.createElement 'div'
    @editorContainer.classList.add 'editor-container'
    @editorContainer.classList.add 'native-key-bindings'
    @editorContainer.setAttribute 'tabIndex', -1
    @element.appendChild @editorContainer

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
