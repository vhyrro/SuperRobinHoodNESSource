-- Super Robin Hood bruteforcing script by Vhyrro --

-- Configuration --
local success_y_pos = { 142, 60 }    -- The y position range to signify that our clip was successful (e.g. { 162, 158 })
local x_range = { -52, 0 }           -- Specifies the relative x range for the bruteforce
local x_leap = 1					 -- Defines how much we should step in the bruteforcing for loop
local x_subpixel_leap = 2			 -- Defines how much we should step in the bruteforcing for loop
local velocity_leap = 1				 -- Defines how much we should step in the bruteforcing for loop

-- Addresses --
local robin_x_subpixel_position = 0x307
local robin_x_position = 0x308
local robin_y_position = 0x30A
local robin_velocity = 0x311
local robin_hasjumped = 0x317
local robin_crouching = 0x315
local robin_leftright = 0x30D
local robin_height = 0x316

-- Logic variables --
local current_x = memory.read_u16_le(robin_x_position)           -- Robin's x position before the bruteforce
local current_y = memory.read_u8(robin_y_position)               -- Robin's y position before the bruteforce
local current_height = memory.read_u8(robin_height)
local current_facing_direction = memory.read_s8(robin_leftright) -- Whether Robin was facing left or right before the bruteforce
local amount_of_tries = 0
local amount_of_hits = 0

console.clear()

console.log("---------- VHYRRO's BRUTEFORCING SCRIPT STARTED ----------")

console.log("X: ", current_x)
console.log("Y: ", current_y)
console.log("Currently facing: ", current_facing_direction)

-- Draws all the UI elements (duh) --
function draw_gui_elements(x, subpixel, velocity)
	gui.text(0, 0, "Currently bruteforcing :)", nil, "topleft")
	gui.text(0, 15, "Testing subpixel = " .. subpixel, nil, "topleft")
	gui.text(0, 30, "Testing x = " .. current_x + x, nil, "topleft")
	gui.text(0, 45, "Testing velocity = " .. velocity, nil, "topleft")
	gui.text(0, 60, "Amount of tries: " .. amount_of_tries, nil, "topleft")
	gui.text(0, 75, "Amount of tries left: " .. (((x_range[2] - x_range[1]) / x_leap) * (255 / x_subpixel_leap) * (47 / velocity_leap)) - amount_of_tries, nil, "topleft")
	gui.text(0, 90, "Amount of hits: " .. amount_of_hits, nil, "topleft")
end

-- Depending on our original direction we were facing before the bruteforce, jump in that direction --
function try_and_hold_jump()

	if current_facing_direction == -1 then
			joypad.set({A=true, Left=true}, 1)
	else
			joypad.set({A=true, Right=true}, 1)
	end

end

-- Bruteforce time --

for subpixel = 1, 255, x_subpixel_leap do -- Go through every possible subpixel

	for x = x_range[1], x_range[2] do -- Go through every possible x position defined by the user

		for velocity = 1, 47, velocity_leap do -- Go through every possible velocity

			-- Reset all memory values to their desired positions --

			memory.write_u16_le(robin_x_position, current_x + x)
			memory.write_u8(robin_y_position, current_y)
			memory.write_u8(robin_velocity, velocity)
			memory.write_u8(robin_x_subpixel_position, subpixel)
			memory.write_u8(robin_crouching, 0) -- With higher velocities, robin would crouch, breaking everything
			memory.write_u8(robin_hasjumped, 0)
			memory.write_u8(robin_height, current_height)

			-- Try and jump --
			try_and_hold_jump()

			-- Wait for 3 frames (to fully allow Robin to jump) --
			for i = 1,3 do

				draw_gui_elements(x, subpixel, velocity)
				emu.frameadvance()
				try_and_hold_jump()

			end

			-- Until Robin hasn't touched ground, advance the emulator --
			while memory.read_u8(robin_hasjumped) == 1 do

				draw_gui_elements(x, subpixel, velocity)
				emu.frameadvance()

			end

			memory.write_u8(robin_velocity, 0)
			memory.write_u8(robin_crouching, 0)

			draw_gui_elements(x, subpixel, velocity)

			-- We should have touched ground by now, check Robin's y position! If it's in our desired range, that means we clipped! --

			local y = memory.read_u8(robin_y_position)

			if y <= success_y_pos[1] and y >= success_y_pos[2] then

				amount_of_hits = amount_of_hits + 1
				console.log("We got a hit! x position: " ..  current_x + x .. ", subpixel position: " .. subpixel .. ", velocity: " .. velocity, ", y position: " .. y)

			end

			amount_of_tries = amount_of_tries + 1

			emu.frameadvance()

		end

	end

end