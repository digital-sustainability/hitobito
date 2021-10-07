
app = window.App ||= {}

app.MessageRecipientInfo = {
  refreshRecipientInfo: (e) ->
    select = $('select#message_send_to_households')
    return if select.length == 0
    defaultHouseholdsSelected = select.find('option[selected="selected"]')[0].value == "true"
    householdsSelected = e.target.value == 'true' || defaultHouseholdsSelected
    
    prefix = if !householdsSelected then 'households' else 'recipient'
    valid_count_one_element = $("#valid_#{prefix}_info_one")
    valid_count_other_element = $("#valid_#{prefix}_info_one")
    invalid_count_one_element = $("#invalid_#{prefix}_info_one")
    invalid_count_other_element = $("#invalid_#{prefix}_info_other")

    valid_count_one_element[0].style.display = 'none'
    valid_count_other_element[0].style.display = 'none'
    invalid_count_one_element[0].style.display = 'none'
    invalid_count_other_element[0].style.display = 'none'

    url = select.data('recipient-count-url')
    messageType = select.data('message-type')

    app.request = $.get(url, { households: householdsSelected, message_type: messageType }, (data) ->
      prefix = if householdsSelected then 'households' else 'recipient'

      if data.valid_recipient_count == 1
        valid_count_one_element = $("#valid_#{prefix}_info_one")

        valid_count_one_element[0].style.display = 'inline'
      else
        valid_count_other_element = $("#valid_#{prefix}_info_one")
        valid_count_other_element.find('#recipient_info_valid_count')[0].innerHTML = data.valid_recipient_count
        valid_count_other_element[0].style.display = 'inline'

      if data.invalid_recipient_count == 1
        invalid_count_one_element = $("#invalid_#{prefix}_info_one")
        invalid_count_one_element[0].style.display = 'inline'
      else if data.invalid_recipient_count > 1
        invalid_count_other_element = $("#invalid_#{prefix}_info_other")
        invalid_count_other_element.find('#recipient_info_invalid_count')[0].innerHTML = data.invalid_recipient_count
        invalid_count_other_element[0].style.display = 'inline'
    )

}

$(document).on('change', 'select#message_send_to_households', app.MessageRecipientInfo.refreshRecipientInfo)
$(document).on('turbolinks:load', app.MessageRecipientInfo.refreshRecipientInfo)
