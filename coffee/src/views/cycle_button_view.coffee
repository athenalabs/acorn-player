goog.provide 'acorn.player.CycleButtonView'



class acorn.player.CycleButtonView extends athena.lib.View


  className: @classNameExtend 'cycle-button-view'


  events: => _.extend super,
    'click button': @_onClickButton
    'change input': @_onChangeInput
    'blur input': @_onChangeInput


  staticButtonTemplate: _.template '''
    <div class="input-prepend input-append cycle-button static-button
        cycle-index-<%= index %>">
      <button class="btn" type="button"><%= buttonName %></button>
      <span class="add-on static-value"><%= value %></span>
    </div>
    '''


  inputButtonTemplate: _.template '''
    <div class="input-prepend cycle-button input-button
        cycle-index-<%= index %>">
      <button class="btn" type="button"><%= buttonName %></button>
      <input size="16" type="text">
    </div>
    '''


  initialize: =>
    @buttonName = @options.buttonName ? ''
    @data = @options.data ? MissingParameterError 'CycleButton', 'data'


  render: =>
    super
    @$el.empty()

    @views = []

    # build views from data
    for i in [0...@data.length]
      data = @data[i]
      constructor = switch data?.type
        when 'static' then @_staticButtonWithData
        when 'input' then @_inputButtonWithData

      unless constructor?
        ValueError 'data', "invalid type for data element #{i}"

      btn = $ constructor _.defaults {index: i++, buttonName: @buttonName}, data
      @views.push btn
      @$el.append btn

    # show correct button view without selecting input
    @showView @options.initialView ? 0, true

    @


  _staticButtonWithData: (data) =>
    @staticButtonTemplate data


  _inputButtonWithData: (data) =>
    view = $ @inputButtonTemplate data
    view.find('input').val data.value ? ''
    view


  showView: (index, dontSelectInput) =>
    for view in @views
      view.addClass 'hidden'

    # get positive modded index
    index %= @views.length
    @currentIndex = if index >= 0 then index else index + @views.length

    shown = @views[@currentIndex].removeClass 'hidden'

    unless dontSelectInput
      shown.find('input').select()
      @_lastInputValue = shown.find('input').val()

    @_change 'view'

    shown


  currentState: =>
    data = @data[@currentIndex]
    view = @views[@currentIndex]

    value = switch data.type
      when 'static' then data.value
      when 'input' then view.find('input').val()

    # return the current view, its name, and its value
    view: view, name: data.name, value: value


  _change: (changed) =>
    switch changed
      when 'view' then @trigger 'change:view', @currentState()
      when 'input' then @trigger 'change:input-value', @currentState()

    @trigger 'change:value', @currentState()


  _onClickButton: =>
    @showView @currentIndex + 1


  _onChangeInput: =>
    index = @views[@currentIndex].find('input')
    value = index.val()
    validate = @data[@currentIndex].validate

    if _.isFunction validate
      validated = validate value

    if validated?
      index.val validated
      @_lastInputValue = validated
      @_change 'input'
    else
      index.val @_lastInputValue
