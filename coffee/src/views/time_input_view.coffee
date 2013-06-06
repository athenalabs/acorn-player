goog.provide 'acorn.player.TimeInputView'



class acorn.player.TimeInputView extends athena.lib.View


  className: @classNameExtend 'time-input-view'


  defaults: => _.extend super,
    padTime: true
    label: null      # side | top | null

  events: => _.extend super,
    'change input': @_onInputChanged
    'blur input': @_onInputChanged
    'keyup input': @_onKeyup


  template: _.template '''
    <div class="control-group time-field time">

      <% if (label == 'side') { %>
      <div class="input-prepend">
        <span class="add-on time-input-label"><%= name %></span>
      <% } else { %>
        <div class="input">
      <% } %>

        <input size="16" type="text" class="time-field time">
      </div>
    </div>
    '''


  initialize: =>
    super

    @_min = @options.min ? 0
    @_max = @options.max ? Infinity

    # starting time value is allowed to be undefined
    @_time = @_bound @options.value if @options.value?


  render: =>
    super
    @$el.empty()

    @$el.append @template
      name: @options.name
      label: @options.label

    @input = @$ 'input.time-field'
    @controlGroup = @$ '.control-group.time-field'

    # set starting time value
    @_setInput true
    if @options.label == 'top'
      @$el.prepend "<span class='time-input-label'>#{@options.name}</span>"

    @$el.addClass "label-#{@options.label}"
    @


  # get/setter for time
  value: (val) =>
    @_handleInput val if val?
    @_time


  setMin: (min) =>
    return unless _.isNumber(min) and !_.isNaN min

    # update min and call onInputChanged in case current time is now invalid
    @_min = min
    @_onInputChanged()


  setMax: (max) =>
    return unless _.isNumber(max) and !_.isNaN max

    @_max = max

    # if current input is invalid, set to max value, else handle state change
    invalidInput = _.isNaN parseFloat @input.val()
    if invalidInput then @_handleInput @_max else @_onInputChanged()


  _bound: (val) =>
    Math.max(@_min, Math.min((val ? 0), @_max))


  # handle DOM and programatic inputs
  _handleInput: (time) =>
    invalidInput = _.isNaN parseFloat time
    seconds = time
    if _.isString seconds
      seconds = acorn.util.Time.timestringToSeconds seconds
    seconds = @_bound seconds

    # if input is invalid or hasn't changed, reset input and return
    if invalidInput or seconds == @_time
      @_setInput true
      return

    @_time = seconds
    @_change()


  _change: =>
    @_setInput()
    @trigger 'TimeInputView:TimeDidChange', @_time


  _setInput: (silent) =>
    return unless @rendering

    # display timestring or '--'
    time = if @_time?
      acorn.util.Time.secondsToTimestring @_time, {padTime: @options.padTime}
    else
      '--'

    @input.val time
    @_glow() unless silent


  # glow blue for half a second to highlight a change
  _glow: =>

    # if not already glowing, add blue glow and start counting down to fade
    unless @_glowCount? and @_glowCount > 0
      @controlGroup.addClass 'info'
      @_glowCounter()

    # wait 5/10ths of a second after last change before fading - reset count on
    # every call to _glow
    @_glowCount = 5


  # decrement the _glowCount every tenth of a second, clearing the highlight and
  # self-destructing when enough time has passed without a call to _glow
  _glowCounter: =>
    @_glowInterval = setInterval (=>
      if --@_glowCount <= 0
        clearInterval @_glowInterval
        @controlGroup.removeClass 'info'
    ), 100


  # ### Event Handlers

  _onInputChanged: =>
    @_handleInput @input.val()


  _onKeyup: (e) =>
    switch e.keyCode
      when athena.lib.util.keys.ENTER then @_onInputChanged()
      when athena.lib.util.keys.ESCAPE then @input.blur()

