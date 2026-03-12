extends TextEdit

@onready var http_request = $HTTPRequest

func _input(event):
	if event.is_action_pressed("accept") and not editable == false:
		if text.strip_edges() != "":
			upload_score(text.strip_edges())

func upload_score(username: String):
	editable = false
	text = ""
	placeholder_text = "Uploading..."
	
	var iso_string = Time.get_datetime_string_from_system(false, true) + "Z"
	var formatted_score = State.get_formatted_time(State.total_msec)
	var base_url = "https://log.alimad.co/api/log?channel=sertimes"
	var raw_text = iso_string + "+" + username + "+" + formatted_score
	var full_url = base_url + "&text=" + raw_text.uri_encode()
	http_request.request(full_url)

func _on_http_request_request_completed(_result, response_code, _headers, _body):
	visible = false
