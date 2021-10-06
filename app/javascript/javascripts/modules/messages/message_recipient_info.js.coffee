
app = window.App ||= {}

app.MessageRecipientInfo = {
  refreshRecipientInfo: (e) ->
    select = $('select#message_send_to_households')
    return if select.length == 0
    householdsSelected = select.find('option[selected="selected"]')[0].value == "true"

    url = select.data('recipient-count-url')
    messageType = select.data('message-type')
    app.request = $.get(url, { households: householdsSelected, message_type: messageType }, (data) ->
      console.log(data.valid_recipient_count)
    )

}

$(document).on('change', 'select#message_send_to_households', app.MessageRecipientInfo.refreshRecipientInfo)
$(document).on('turbolinks:load', app.MessageRecipientInfo.refreshRecipientInfo)
