/*!
 * Range Slider
 *
 * jQuery UI widget for selecting a range. This is an optimized version of the
 * range option for the slider widget built into jQuery UI.
 *
 * Adapted from jQuery UI Slider:
 *   jQuery UI Slider @VERSION
 *   http://jqueryui.com
 *
 *   Copyright 2012 jQuery Foundation and other contributors
 *   Released under the MIT license.
 *   http://jquery.org/license
 *
 *   http://api.jqueryui.com/slider/
 *
 *   Depends:
 *  	jquery.ui.core.js
 *  	jquery.ui.mouse.js
 *  	jquery.ui.widget.js
 */
(function($, undefined) {

// number of pages in a slider
// (how many times can you page up/down to go through the whole range)
var numPages = 5;

$.widget("ui.rangeslider", $.ui.mouse, {
  version: "@VERSION",
  widgetEventPrefix: "rangeslide",

  options: {
    animate: false,
    distance: 0,
    max: 100,
    min: 0,
    orientation: "horizontal",
    step: 1,
    values: null,
  },

  _create: function() {
    var i, handleCount,
        o = this.options,
        existingHandles = this.element.find(".ui-slider-handle").
            addClass("ui-state-default ui-corner-all"),
        handle = "<a class='ui-slider-handle ui-state-default ui-corner-all' " +
            "href='#'></a>",
        handles = [];

    this._keySliding = false;
    this._mouseSliding = false;
    this._animateOff = true;
    this._handleIndex = null;
    this._detectOrientation();
    this._mouseInit();

    this.element
        .addClass(
          "ui-slider" +
          " ui-slider-" + this.orientation +
          " ui-widget" +
          " ui-widget-content" +
          " ui-corner-all"
        );

    if (!o.values) {
      o.values = [this._valueMin(), this._valueMin()];
    };
    if (o.values.length && o.values.length !== 2) {
      o.values = [o.values[0], o.values[0]];
    };

    this.range = $("<div></div>")
        .appendTo(this.element)
        .addClass(
          "ui-slider-range" +
          // note: this isn't the most fittingly semantic framework class
          // for this element, but worked best visually with a variety of
          // themes
          " ui-widget-header"
        );

    handleCount = 2;

    for (i = existingHandles.length; i < handleCount; i++) {
      handles.push(handle);
    };

    this.handles = existingHandles.add($(handles.join(""))
        .appendTo(this.element));

    this.handle = this.handles.eq(0);

    this.handles.add(this.range).filter("a")
        .click(function(event) {
          event.preventDefault();
        })
        .mouseenter(function() {
          if (!o.disabled) {
            $(this).addClass("ui-state-hover");
          };
        })
        .mouseleave(function() {
          $(this).removeClass("ui-state-hover");
        })
        .focus(function() {
          if (!o.disabled) {
            $(".ui-slider .ui-state-focus").removeClass("ui-state-focus");
            $(this).addClass("ui-state-focus");
          } else {
            $(this).blur();
          };
        })
        .blur(function() {
          $(this).removeClass("ui-state-focus");
        });

    this.handles.each(function(i) {
      $(this).data("ui-slider-handle-index", i);
    });

    this._setOption("disabled", o.disabled);

    this._on(this.handles, {
      keydown: function(event) {
        var allowed, curVal, newVal, step,
            index = $(event.target).data("ui-slider-handle-index");

        switch (event.keyCode) {
          case $.ui.keyCode.HOME:
          case $.ui.keyCode.END:
          case $.ui.keyCode.PAGE_UP:
          case $.ui.keyCode.PAGE_DOWN:
          case $.ui.keyCode.UP:
          case $.ui.keyCode.RIGHT:
          case $.ui.keyCode.DOWN:
          case $.ui.keyCode.LEFT:
            event.preventDefault();
            if (!this._keySliding) {
              this._keySliding = true;
              $(event.target).addClass("ui-state-active");
              allowed = this._start(event, index);
              if (allowed === false) {
                return;
              };
            };
            break;
        };

        step = this.options.step;
        curVal = newVal = this.values(index);

        switch (event.keyCode) {
          case $.ui.keyCode.HOME:
            newVal = this._valueMin();
            break;
          case $.ui.keyCode.END:
            newVal = this._valueMax();
            break;
          case $.ui.keyCode.PAGE_UP:
            newVal = this._trimAlignValue(curVal + ((this._valueMax() -
                this._valueMin()) / numPages));
            break;
          case $.ui.keyCode.PAGE_DOWN:
            newVal = this._trimAlignValue(curVal - ((this._valueMax() -
                this._valueMin()) / numPages));
            break;
          case $.ui.keyCode.UP:
          case $.ui.keyCode.RIGHT:
            if (curVal === this._valueMax()) {
              return;
            };
            newVal = this._trimAlignValue(curVal + step);
            break;
          case $.ui.keyCode.DOWN:
          case $.ui.keyCode.LEFT:
            if (curVal === this._valueMin()) {
              return;
            };
            newVal = this._trimAlignValue(curVal - step);
            break;
        };

        this._slide(event, index, newVal);
      },
      keyup: function(event) {
        var index = $(event.target).data("ui-slider-handle-index");

        if (this._keySliding) {
          this._keySliding = false;
          this._stop(event, index);
          this._change(event, index);
          $(event.target).removeClass("ui-state-active");
        };
      },
    });

    this._refreshValues();

    this._animateOff = false;
  },

  _destroy: function() {
    this.handles.remove();
    this.range.remove();

    this.element.removeClass(
      "ui-slider" +
      " ui-slider-horizontal" +
      " ui-slider-vertical" +
      " ui-widget" +
      " ui-widget-content" +
      " ui-corner-all"
    );

    this._mouseDestroy();
  },

  _mouseCapture: function(event) {
    var position, normValue, distance, closestHandle, index, allowed, offset,
        mouseOverHandle, that = this, o = this.options;

    if (o.disabled) {
      return false;
    };

    this.elementSize = {
      width: this.element.outerWidth(),
      height: this.element.outerHeight()
    };
    this.elementOffset = this.element.offset();

    position = { x: event.pageX, y: event.pageY };
    normValue = this._normValueFromMouse(position);
    distance = this._valueMax() - this._valueMin() + 1;

    this.handles.each(function(i) {
      var thisDistance = Math.abs(normValue - that.values(i));

      if ((distance > thisDistance) ||
        (distance === thisDistance &&
          (i === that._lastChangedValue || that.values(i) === o.min))) {
        distance = thisDistance;
        closestHandle = $(this);
        index = i;
      };
    });

    allowed = this._start(event, index);
    if (allowed === false) {
      return false;
    };
    this._mouseSliding = true;

    this._handleIndex = index;

    closestHandle.addClass("ui-state-active").focus();

    offset = closestHandle.offset();
    mouseOverHandle = this.handles.hasClass("ui-state-hover");
    this._clickOffset = !mouseOverHandle ? { left: 0, top: 0 } : {
      left: event.pageX - offset.left - (closestHandle.outerWidth() / 2),
      top: event.pageY - offset.top -
        (closestHandle.outerHeight() / 2) -
        (parseInt(closestHandle.css("borderTopWidth"), 10) || 0) -
        (parseInt(closestHandle.css("borderBottomWidth"), 10) || 0) +
        (parseInt(closestHandle.css("marginTop"), 10) || 0),
    };

    if (!mouseOverHandle) {
      this._slide(event, index, normValue);
    };
    this._animateOff = true;
    return true;
  },

  _mouseStart: function() {
    return true;
  },

  _mouseDrag: function(event) {
    var position, normValue;
    
    position = { x: event.pageX, y: event.pageY };
    normValue = this._normValueFromMouse(position);

    this._slide(event, this._handleIndex, normValue);

    return false;
  },

  _mouseStop: function(event) {
    this.handles.removeClass("ui-state-active");
    this._mouseSliding = false;

    this._stop(event, this._handleIndex);
    this._change(event, this._handleIndex);

    this._handleIndex = null;
    this._clickOffset = null;
    this._animateOff = false;

    return false;
  },

  _detectOrientation: function() {
    if (this.options.orientation === "vertical")
      this.orientation = "vertical";
    else
      this.orientation = "horizontal";
  },

  _normValueFromMouse: function(position) {
    var pixelTotal, pixelMouse, percentMouse, valueTotal, valueMouse;

    if (this.orientation === "horizontal") {
      pixelTotal = this.elementSize.width;
      pixelMouse = position.x - this.elementOffset.left - (this._clickOffset ?
          this._clickOffset.left : 0);
    } else {
      pixelTotal = this.elementSize.height;
      pixelMouse = position.y - this.elementOffset.top - (this._clickOffset ?
          this._clickOffset.top : 0);
    };

    percentMouse = (pixelMouse / pixelTotal);
    if (percentMouse > 1) {
      percentMouse = 1;
    };
    if (percentMouse < 0) {
      percentMouse = 0;
    };
    if (this.orientation === "vertical") {
      percentMouse = 1 - percentMouse;
    };

    valueTotal = this._valueMax() - this._valueMin();
    valueMouse = this._valueMin() + percentMouse * valueTotal;

    return this._trimAlignValue(valueMouse);
  },

  _start: function(event, index) {
    var uiHash = {
      handle: this.handles[index],
      values: this.values(),
    };

    return this._trigger("start", event, uiHash);
  },

  _slide: function(event, index, newVal) {
    var otherVal, valuesCrossed, newValues, allowed;

    otherVal = this.values(index ? 0 : 1);

    valuesCrossed = index === 0 && newVal > otherVal ||
        index === 1 && newVal < otherVal;

    if (valuesCrossed)
      newVal = otherVal;

    if (newVal !== this.values(index)) {
      newValues = this.values();
      newValues[index] = newVal;
      // A slide can be canceled by returning false from the slide callback
      allowed = this._trigger("slide", event, {
        handle: this.handles[index],
        values: newValues
      });
      if (allowed !== false) {
        this.values(index, newVal, true);
      };
    };
  },

  _stop: function(event, index) {
    var uiHash = {
      handle: this.handles[index],
      values: this.values(),
    };

    this._trigger("stop", event, uiHash);
  },

  _change: function(event, index) {
    if (!this._keySliding && !this._mouseSliding) {
      var uiHash = {
        handle: this.handles[index],
        values: this.values(),
      };

      // store the last changed value index for reference when handles overlap
      this._lastChangedValue = index;

      this._trigger("change", event, uiHash);
    };
  },

  values: function(index, newValue) {
    var vals, newValues, i;

    if (arguments.length > 1) {
      this.options.values[index] = this._trimAlignValue(newValue);
      this._refreshValues();
      this._change(null, index);
      return;
    };

    if (arguments.length) {
      if ($.isArray(arguments[0])) {
        vals = this.options.values;
        newValues = arguments[0];
        for (i = 0; i < vals.length; i += 1) {
          vals[i] = this._trimAlignValue(newValues[i]);
          this._change(null, i);
        };
        this._refreshValues();
      } else {
        return this._values(index);
      };
    } else {
      return this._values();
    };
  },

  _setOption: function(key, value) {
    var i;

    $.Widget.prototype._setOption.apply(this, arguments);

    switch (key) {
      case "disabled":
        if (value) {
          this.handles.filter(".ui-state-focus").blur();
          this.handles.removeClass("ui-state-hover");
          this.handles.prop("disabled", true);
        } else {
          this.handles.prop("disabled", false);
        };
        break;
      case "orientation":
        this._detectOrientation();
        this.element
          .removeClass("ui-slider-horizontal ui-slider-vertical")
          .addClass("ui-slider-" + this.orientation);
        this._refreshValues();
        break;
      case "values":
        this._animateOff = true;
        this._refreshValues();
        for (i = 0; i < this.options.values.length; i += 1) {
          this._change(null, i);
        };
        this._animateOff = false;
        break;
      case "min":
      case "max":
        this._animateOff = true;
        this._refreshValues();
        this._animateOff = false;
        break;
    };
  },

  // internal values getter
  // _values() returns array of values trimmed by min and max, aligned by step
  // _values(index) returns single value trimmed by min and max, aligned by step
  _values: function(index) {
    var val, vals, i;

    if (arguments.length) {
      val = this.options.values[index];
      val = this._trimAlignValue(val);

      return val;
    } else {
      // .slice() creates a copy of the array
      // this copy gets trimmed by min and max and then returned
      vals = this.options.values.slice();
      for (i = 0; i < vals.length; i+= 1) {
        vals[i] = this._trimAlignValue(vals[i]);
      };

      return vals;
    };
  },

  // returns the step-aligned value that val is closest to, between (inclusive) min and max
  _trimAlignValue: function(val) {
    var step, valModStep, alignValue;

    if (val <= this._valueMin()) {
      return this._valueMin();
    };
    if (val >= this._valueMax()) {
      return this._valueMax();
    };

    step = (this.options.step > 0) ? this.options.step : 1;
    valModStep = (val - this._valueMin()) % step;
    alignValue = val - valModStep;

    if (Math.abs(valModStep) * 2 >= step) {
      alignValue += (valModStep > 0) ? step : (-step);
    };

    // Since JavaScript has problems with large floats, round
    // the final value to 5 digits after the decimal point (see #4124)
    return parseFloat(alignValue.toFixed(5));
  },

  _valueMin: function() {
    return this.options.min;
  },

  _valueMax: function() {
    return this.options.max;
  },

  _refreshValues: function() {
    var lastValPercent, valPercent, o, animate, _set = {}, that = this;

    o = this.options;
    animate = (!this._animateOff) ? o.animate : false;

    this.handles.each(function(i) {
      valPercent = (that.values(i) - that._valueMin()) /
          (that._valueMax() - that._valueMin()) * 100;
      _set[that.orientation === "horizontal" ? "left" : "bottom"] =
          valPercent + "%";
      $(this).stop(1, 1)[animate ? "animate" : "css"](_set,
          o.animate);
      if (that.orientation === "horizontal") {
        if (i === 0) {
          that.range.stop(1, 1)[animate ? "animate" : "css"](
              { left: valPercent + "%" },
              o.animate);
        };
        if (i === 1) {
          that.range[animate ? "animate" : "css"](
              { width: (valPercent - lastValPercent) + "%" },
              { queue: false, duration: o.animate });
        };
      } else {
        if (i === 0) {
          that.range.stop(1, 1)[animate ? "animate" : "css"](
              { bottom: (valPercent) + "%" },
              o.animate);
        };
        if (i === 1) {
          that.range[animate ? "animate" : "css"](
              { height: (valPercent - lastValPercent) + "%" },
              { queue: false, duration: o.animate });
        };
      };
      lastValPercent = valPercent;
    });
  },

});

}(jQuery));
