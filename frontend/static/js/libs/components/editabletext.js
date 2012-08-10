//     editabletext.js 1.0
//     (c) 2012 Juan Batiz-Benet.
//     Backbone.js component
//     Acorn is freely distributable under the MIT license.

(function() {

  // Setup
  // -----

  // Establish the root object, `window` in browser, or `global` on server.
  var root = this;

  // For our purposes, jQuery, Zepto, or Ender owns the `$` variable.
  var $ = root.jQuery || root.Zepto || root.ender;

  // Underscore and Backbone
  var _ = root._;
  var Backbone = root.Backbone;

  // Define our root Object
  var EditableTextCmp = {};

  // Register components
  if (Backbone.components === undefined)
    Backbone.components = {};
  Backbone.components.EditableTextCmp = EditableTextCmp;

  // Util functions

  var _lastId = 1;
  EditableTextCmp.nextId = function() {
    return 'editabletext' + _lastId++;
  };

  // Setup template.
  EditableTextCmp.template = _.template("\
  <div class='editabletext' id='<%= id %>'>\
    <div id='<%= id %>_text'>\
      <%= html %>\
      <% if (addToggle) { %><small id='toggle'>edit</small><% } %>\
    </div>\
    <% if (multiline) { %>\
    <textarea id='<%= id %>_edit' style='display: none;'><%= text %></textarea>\
    <% } else { %>\
      <input type='text' id='<%= id %>_edit'\
        placeholder='<%= placeholder %>'\
        style='display: none;' value='<%= text %>' />\
    <% } %>\
  </div>\
  ");

  // Setup view.
  EditableTextCmp.View = Backbone.View.extend({

    template: EditableTextCmp.template,

    // Delegated events for creating new items, and clearing completed ones.
    events: {
      "keypress textarea":  "saveOnEnter",
      "keypress input":  "saveOnEnter",
      "click #toggle": "toggle"
    },


    initialize: function() {
      _.bindAll(this, 'saveOnEnter', 'toggle');

      if (!this.options.textFn) {
        throw new Error("EditableTextCmp requires option textFn.");
      }

      this.options.html = this.options.html || function(_) { return _; }
      this.options.multiline = !!this.options.multiline;
      this.options.addToggle = !!this.options.addToggle;
      this.options.characterLimit = parseInt(this.options.characterLimit) || -1;
      this.options.enterSaves = this.options.enterSaves || true;
      this.options.placeholder = this.options.placeholder || '';
      this.options.id = this.options.id || EditableTextCmp.nextId();
    },

    render: function() {
      var text_ = this.options.textFn();

      $(this.el).html(this.template({
        id: this.options.id,
        text: text_ || '',
        html: this.html(text_ || ''),
        multiline: this.options.multiline,
        placeholder: this.options.placeholder,
        addToggle: this.isEditable() && this.options.addToggle
      }));

      if (this.options.help) {
        this.find(".editabletext > #edit").popover(this.options.help);
      }

      if (this.isEditable() && this.options.externalToggle) {
        $(this.options.externalToggle).text('edit');

        var event = 'click.edit_' + this.options.id;
        $(this.options.externalToggle).off(event);
        $(this.options.externalToggle).on(event, this.toggle);
      }

      // adjust text size to match container
      this.find('.editabletext > #text').css('width', '100%');
      this.find('.editabletext > #text').css('height', '100%');
    },

    find: function(sel) {
      // add the randomly generated id in between.
      var id = $(this.el).find('.editabletext').attr('id');
      return $(this.el).find(sel.replace(/#/g, '#' + id + '_'));
    },

    // add any transforms from text to display html.
    html: function(text) {
      text = this.options.html(text);
      text = text.replace(/\n/gi, '<br />');
      return text;
    },

    isEditing: false,
    isEditable: function() {
      switch (typeof this.options.editable) {
        case 'function': return this.options.editable();
        case 'undefined': return true;
        default: return !!this.options.editable;
      }
    },

    edit: function() {
      if (!this.isEditable())
        return;

      var field = this.find(".editabletext > #edit");
      var text = this.find(".editabletext > #text");

      var leftPad = (this.options.multiline ? 5 : 6);
      var topPad = 5;

      field.css("width", text.css("width"));
      field.css("height", text.css("height"));
      field.css("font", text.css("font"));
      field.css("margin-left", parseInt(text.css("margin-left")) - leftPad);
      field.css("margin-top", parseInt(text.css("margin-top")) - topPad);

      text.hide();
      field.show();
      field.focus();
      field.value = field.value; // to move cursor to end.

      this.isEditing = true;

      if (this.options.externalToggle)
        $(this.options.externalToggle).text('save');

      if (this.options.onEdit)
        this.options.onEdit();
    },

    saveText: function() {
      return this.find(".editabletext > #edit").val()
    },

    save: function() {
      if (!this.isEditable())
        return;

      var text = this.saveText();

      // close popover
      this.find(".editabletext > #edit").tooltip('hide');

      // Attempt to validate
      if (this.options.validate) {
        var result = this.options.validate(text);
        if (result) {

          // validation failed. show help, and return
          this.find(".editabletext > #edit").tooltip({ title: result });
          this.find(".editabletext > #edit").tooltip('show');
          return;
        }
      }

      // save and render
      this.options.textFn(text);
      this.render();
      this.isEditing = false;

      if (this.options.externalToggle)
        $(this.options.externalToggle).text('edit');

      if (this.options.onSave)
        this.options.onSave();
    },

    toggle: function() {
      this.isEditing ? this.save() : this.edit();
    },

    saveOnEnter: function(e) {
      if (e.keyCode == 13 && this.isEditing &&
          !!this.options.enterSaves && !e.shiftKey) {
        this.save();
        return false;
      }

      var limit = this.options.characterLimit;
      var cleft = limit - this.saveText().length;
      if (limit >= 0) {
        $(this.el).tooltip({title: cleft + ' characters left.'});
      }
      if (limit >= 0 && cleft <= 0) {
        // over the limit.
        return false;
      }

    },

    alert: function(text) {
      this.find('.editabletext > #edit').css("class", "error");
      this.find('.editabletext > #edit').popover({
        title: "Error: invalid text.",
        body: text,
        trigger: 'manual',
      });
    },

  });

  return EditableTextCmp;
}).call(this);
