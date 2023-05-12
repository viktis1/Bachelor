# ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# MIMO radar demonstrator - TCL-control script
# TCL template for MS3
# ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
puts "Halting TX, resetting RX BRAM" 
# Halt TX 
mwr -force 0xA0047000 0 
# Reset BRAM 
mwr -force 0xA0047000 2 
# Done 
mwr -force 0xA0047000 0 
puts "Enable all TX channels" 
mwr -force 0xA0047008 255 
puts "Uploading waveforms to ZCU111" 
# Channel 0 
dow -force -data iq_sequence__waveform_01.bin 0xA0900000 
# Channel 1 
dow -force -data iq_sequence__waveform_02.bin 0xA0904000 
# Channel 2 
dow -force -data iq_sequence__waveform_03.bin 0xA0908000 
# Channel 3 
dow -force -data iq_sequence__waveform_04.bin 0xA090C000 
# Channel 4 
dow -force -data iq_sequence__waveform_05.bin 0xA0910000 
# Channel 5 
dow -force -data iq_sequence__waveform_06.bin 0xA0914000 
# Channel 6 
dow -force -data iq_sequence__waveform_07.bin 0xA0918000 
# Channel 7 
dow -force -data iq_sequence__waveform_08.bin 0xA091C000 
# Now configure the system 
puts "Configuring system" 
# Trigger period = XXXX ms + XXXX µs to ensure RX duration contained
mwr -force 0xA0040000 1 
mwr -force 0xA0040008 0 
# TX delay 0 
mwr -force 0xA0041000 0 
mwr -force 0xA0041008 0 
mwr -force 0xA0042000 0 
mwr -force 0xA0042008 0 
mwr -force 0xA0043000 0 
mwr -force 0xA0043008 0 
mwr -force 0xA0044000 0 
mwr -force 0xA0044008 0 
# No burst mode utilized
mwr -force 0xA0045000 0 
mwr -force 0xA0045008 0 
# No trigger-to-RX delay 
mwr -force 0xA0046000 0 
# Record for XXXX µs ( XXXX x 62.5 ns periods) 
mwr -force 0xA0046008 0 

# Start transmitting and recording! 
mwr -force 0xA0047000 1 
# Delay before ending recording
puts "Pause for transfer"
after 1000
# Stop recording
mwr -force 0xA0047000 0 
puts "Finished"





