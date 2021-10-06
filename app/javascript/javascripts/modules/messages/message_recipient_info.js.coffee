
app = window.App ||= {}

app.MessageRecipientInfo = {
  refreshRecipientInfo: (e) ->
    select = $('select#message_send_to_households')
    return if select.length == 0
    defaultHouseholdsSelected = select.find('option[selected="selected"]')[0].value == "true"
    householdsSelected = e.target.value == 'true' || defaultHouseholdsSelected
    
    valid_count_one_element = $('#valid_recipient_info_one')
    valid_count_other_element = $('#valid_recipient_info_other')
    invalid_count_one_element = $('#invalid_recipient_info_one')
    invalid_count_other_element = $('#invalid_recipient_info_other')

    valid_count_one_element[0].style.display = 'hidden'
    valid_count_other_element[0].style.display = 'hidden'
    invalid_count_one_element[0].style.display = 'hidden'
    invalid_count_other_element[0].style.display = 'hidden'

    url = select.data('recipient-count-url')
    messageType = select.data('message-type')

    app.request = $.get(url, { households: householdsSelected, message_type: messageType }, (data) ->
      if data.valid_recipient_count == 1
        valid_count_one_element[0].style.display = 'inline'
      else
        valid_count_other_element.find('#recipient_info_valid_count')[0].innerHTML = data.valid_recipient_count
        valid_count_other_element[0].style.display = 'inline'

      if data.invalid_recipient_count == 1
        invalid_count_one_element[0].style.display = 'inline'
      else if data.invalid_recipient_count > 1
        invalid_count_other_element.find('#recipient_info_invalid_count')[0].innerHTML = data.invalid_recipient_count
        invalid_count_other_element[0].style.display = 'inline'
    )

}

$(document).on('change', 'select#message_send_to_households', app.MessageRecipientInfo.refreshRecipientInfo)
$(document).on('turbolinks:load', app.MessageRecipientInfo.refreshRecipientInfo)
