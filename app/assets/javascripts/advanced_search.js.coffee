App.AdvancedSearch =

  advanced_search_terms: ->
    $("#js-advanced-search-list").data("advanced-search-terms")

  advanced_search_sidebar_terms: ->
    $("#js-advanced-search-sidebar").data("advanced-search-terms")

  toggle_form: (event) ->
    event.preventDefault()
    $("#js-advanced-search-list").slideToggle()

  toggle_form_sidebar: (event) ->
    event.preventDefault()
    $("#js-advanced-search-sidebar").slideToggle()

  toggle_date_options: ->
    if $("#js-advanced-search-date-min-list").val() == "custom"
      $("#js-custom-date-list").show()
      $( ".js-calendar-list" ).datepicker( "option", "disabled", false )
    else
      $("#js-custom-date-list").hide()
      $( ".js-calendar-list" ).datepicker( "option", "disabled", true )

  toggle_date_options_sidebar: ->
    if $("#js-advanced-search-date-min-sidebar").val() == "custom"
      $("#js-custom-date-sidebar").show()
      $( ".js-calendar-sidebar" ).datepicker( "option", "disabled", false )
    else
      $("#js-custom-date-sidebar").hide()
      $( ".js-calendar-sidebar" ).datepicker( "option", "disabled", true )

  init_calendar: ->
    locale = $("#js-locale").data("current-locale")
    if locale == "en"
      locale = ""

    $(".js-calendar-list").datepicker
      regional: locale
      maxDate: "+0d"
    $(".js-calendar-full").datepicker
      regional: locale

  init_calendar_sidebar: ->
    locale = $("#js-locale").data("current-locale")
    if locale == "en"
      locale = ""

    $(".js-calendar-sidebar").datepicker
      regional: locale
      maxDate: "+0d"
    $(".js-calendar-full").datepicker
      regional: locale

  initialize: ->
    App.AdvancedSearch.init_calendar()
    App.AdvancedSearch.init_calendar_sidebar()

    if App.AdvancedSearch.advanced_search_terms()
      $("#js-advanced-search-list").show()
      App.AdvancedSearch.toggle_date_options()

    if App.AdvancedSearch.advanced_search_sidebar_terms()
      $("#js-advanced-search-sidebar").show()
      App.AdvancedSearch.toggle_date_options_sidebar()

    $("#js-advanced-search-title-list").on
      click: (event) ->
        App.AdvancedSearch.toggle_form(event)

    $("#js-advanced-search-title-sidebar").on
      click: (event) ->
        App.AdvancedSearch.toggle_form_sidebar(event)

    $("#js-advanced-search-date-min-list").on
      change: ->
        App.AdvancedSearch.toggle_date_options()

    $("#js-advanced-search-date-min-sidebar").on
      change: ->
        App.AdvancedSearch.toggle_date_options_sidebar()
