player_near = place_meeting(x +3, y +3, obj_player);

if (player_near) {

    if (keyboard_check_pressed(ord("E"))) {

        room_goto(target_room);

    }
}