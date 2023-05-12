# ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# MIMO radar demonstrator - TCL-control script
# TCL template for MS1 and MS2
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
# Trigger period = XXXX us + XXXX us to ensure RX duration contained
mwr -force 0xA0040000 0 
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
# Record for XXXX µs (XXXX x 62.5 ns periods) 
mwr -force 0xA0046008 0 
# Start transmitting and recording! 
mwr -force 0xA0047000 1 
puts "System started" 
# Wait for 40 ms 
after 40 
mwr -force 0xA0047000 0 
puts "System stopped" 
# Now download the recorded data 
puts "Downloading data" 
puts "Channel 0" 
mrd -force -size h -bin -file adc_0I.bin 0xA0100000 131072 
mrd -force -size h -bin -file adc_0Q.bin 0xA0140000 131072 
puts "Channel 1" 
mrd -force -size h -bin -file adc_1I.bin 0xA0180000 131072 
mrd -force -size h -bin -file adc_1Q.bin 0xA01C0000 131072 
puts "Channel 2" 
mrd -force -size h -bin -file adc_2I.bin 0xA0200000 131072 
mrd -force -size h -bin -file adc_2Q.bin 0xA0240000 131072 
puts "Channel 3" 
mrd -force -size h -bin -file adc_3I.bin 0xA0280000 131072 
mrd -force -size h -bin -file adc_3Q.bin 0xA02C0000 131072 
puts "Channel 4" 
mrd -force -size h -bin -file adc_4I.bin 0xA0300000 131072 
mrd -force -size h -bin -file adc_4Q.bin 0xA0340000 131072 
puts "Channel 5" 
mrd -force -size h -bin -file adc_5I.bin 0xA0380000 131072 
mrd -force -size h -bin -file adc_5Q.bin 0xA03C0000 131072 
puts "Channel 6" 
mrd -force -size h -bin -file adc_6I.bin 0xA0400000 131072 
mrd -force -size h -bin -file adc_6Q.bin 0xA0440000 131072 
puts "Channel 7" 
mrd -force -size h -bin -file adc_7I.bin 0xA0480000 131072 
mrd -force -size h -bin -file adc_7Q.bin 0xA04C0000 131072 
puts "Finished" 

# Data download for MS2
# DDR-RAM storage - use of adcCapture in Tera Term to reflect the same amount of data
#mrd -force -size b -bin -file adc_from_dma.bin 4194304 0x500000000
