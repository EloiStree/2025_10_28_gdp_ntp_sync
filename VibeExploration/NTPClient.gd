# NTPClient.gd
extends Node

const NTP_SERVER = "pool.ntp.org"
const NTP_PORT = 123
const NTP_TIMESTAMP_DELTA = 2208988800  # seconds between 1900 and 1970

func get_ntp_time() -> float:
    var udp := PacketPeerUDP.new()
    udp.connect_to_host(NTP_SERVER, NTP_PORT)
    if udp.get_status() != PacketPeerUDP.STATUS_CONNECTED:
        push_warning("Failed to connect to NTP server")
        return -1

    # 48-byte NTP request packet (first byte = 0b11100011)
    var request = PackedByteArray([0x1B])  # LI=0, VN=3, Mode=3 (client)
    request.resize(48)
    udp.put_packet(request)

    # Wait briefly for a reply
    var start = Time.get_ticks_msec()
    while udp.get_available_packet_count() == 0 and Time.get_ticks_msec() - start < 2000:
        await get_tree().process_frame()

    if udp.get_available_packet_count() == 0:
        push_warning("No NTP response")
        return -1

    var response = udp.get_packet()
    udp.close()

    # Extract 64-bit "Transmit Timestamp" starting at byte 40
    var seconds := 0
    for i in range(40, 44):
        seconds = (seconds << 8) | response[i]
    var unix_time = float(seconds - NTP_TIMESTAMP_DELTA)
    return unix_time
