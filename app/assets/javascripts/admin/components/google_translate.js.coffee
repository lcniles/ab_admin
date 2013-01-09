# direct to Google API
window.translate = (text, element, from, to) ->
  $.ajax
    url: "https://www.googleapis.com/language/translate/v2"
    dataType: "jsonp"
    data:
      key: 'www'
      q: text
      source: from
      target: to

    success: (result) ->
      translated = result.data.translations[0].translatedText
      element.ck_val $.unescape(translated)

    error: (XMLHttpRequest, textStatus, errorThrown) ->
      alert "Error translate " + text + " message " + textStatus

# throught Rack endpoint
window.google_t = (text, element, from, to) ->
  return '' unless $.trim(text)
  opts = {q: text, from: from, to: to}
  $.post "/translate", opts, ((data) =>
    element.ck_val $.unescape(data.text).replace(/%\s{/g, ' %{')), 'json'

# get value of text field or CKEDITOR area
$.fn.ck_val = (v = null) ->
  $el = $(this)
  el_id = $el.attr('id')
  ck_obj = CKEDITOR?.instances[el_id]
  if ck_obj
    if v
      ck_obj.setData(v)
    else
      ck_obj.getData()
  else
    if v
      $el.val(v)
    else
      $el.val()

class GoogleLocaleTabs
  constructor: ->
    @locales = ['ru', 'en', 'it']
    @limit = 1000
    html = '<div class="t_locales">'
    for l in @locales
      html += "<div class='t_locale t_locale_#{l}'></div>"
    html += '</div>'
    @html = $(html)
    $('.locale_tabs:not(".no_translate") .tab-pane').prepend(@html)
    @initHandlers()

  initHandlers: ->
    _.each $('form .locale_tabs:not(".no_translate")'), (tabs) =>
      $tabs = $(tabs)
      return if $tabs.hasClass('locale_tabs_done')
      $tabs.addClass('locale_tabs_done')
      _.each @locales, (to) =>
        _.each @locales, (from) =>
          $cont_to = $tabs.find(".tab_#{to}")
          $cont_from = $tabs.find(".tab_#{from}")
          $el = $cont_to.find(".t_locale_#{from}")
          $el.click =>
            for el_to in $cont_to.find("input.string, textarea")
              $el_to = $(el_to)
              regexp = RegExp("#{to}$")
              el_from_id = $el_to.attr('id').replace(regexp, from)
              $el_from = $("##{el_from_id}")
              if $el_from.ck_val().length < @limit
                google_t($el_from.ck_val(), $el_to, from, to)

$ ->
  if $('.locale_tabs')[0]
    window.locale_tabs = new GoogleLocaleTabs()