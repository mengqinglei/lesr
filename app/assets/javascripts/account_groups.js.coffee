$ ->
  ($ "a[data-toggle=modal]").click ->
    target = ($ @).attr('data-target')
    url = ($ @).attr('href')
    ($ target).load(url)

  ($ '#default_widget').monthpicker()

  ($ "input.caller").click ->
    if $(this).is(':checked')
      $("input.receiver").attr('checked', true)
    else
      $("input.receiver").attr('checked', false)

