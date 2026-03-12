extends Label

var url := "https://live.alimad.co/ping?app=ser"
var http := HTTPRequest.new()

func _ready():
	add_child(http)
	_loop()

func _loop() -> void:
	while true:
		var err = http.request(url)
		if err == OK:
			var result = await http.request_completed
			var body: PackedByteArray = result[3]
			text = "%s online" % body.get_string_from_utf8()
		else:
			text = "Offline"
		await get_tree().create_timer(10.0).timeout
