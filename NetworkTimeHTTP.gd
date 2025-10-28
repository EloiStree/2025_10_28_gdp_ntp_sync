# NetworkTimeHTTP.gd
extends Node

const TIME_API = "https://worldtimeapi.org/api/timezone/Etc/UTC"

func get_utc_time() -> float:
    var http := HTTPRequest.new()
    add_child(http)
    var err = http.request(TIME_API)
    if err != OK:
        push_warning("Failed to request time API")
        return -1

    var result = await http.request_completed
    var response_code = result[1]
    var body = result[3]
    if response_code != 200:
        push_warning("HTTP error: %d" % response_code)
        return -1

    var data = JSON.parse_string(body.get_string_from_utf8())
    if typeof(data) == TYPE_DICTIONARY and "unixtime" in data:
        return float(data["unixtime"])
    return -1
