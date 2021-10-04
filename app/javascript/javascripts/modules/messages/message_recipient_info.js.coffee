
app = window.App ||= {}

app.MessageRecipientInfo = {
  refreshRecipientInfo: (e) ->
    select = $('select#message_send_to_households')
    debugger
    households_selected = select.find('option[selected=selected]')[0].value == "true"
    console.log(households_selected)
}

$(document).on('change', 'select#message_send_to_households', app.MessageRecipientInfo.refreshRecipientInfo)
$(document).on('turbolinks:load', app.MessageRecipientInfo.refreshRecipientInfo
)
