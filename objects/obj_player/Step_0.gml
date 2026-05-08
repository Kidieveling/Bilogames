var hmove = keyboard_check(vk_right) - keyboard_check(vk_left);
var vmove = keyboard_check(vk_down) - keyboard_check(vk_up);

// Hold Shift to run
var running = move_speed;

if (keyboard_check(vk_shift)) {
    running *= run_speed;
}

x += hmove * running;
y += vmove * running;