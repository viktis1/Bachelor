# ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
# MIMO radar demonstrator - TCL-control script
# TCL template for MS3
# ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
puts "Recording dead-time - TX pause" 
# Halt TX 
mwr -force 0xA0047000 0 
# Reset BRAM 
mwr -force 0xA0047000 2 
# Done 
mwr -force 0xA0047000 0 
# No use of TX - no need to download waveforms to the system
mwr -force 0xA0047008 0 
# Trigger period = XXXX ms + XXXX µs to ensure RX duration contained
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
# Record for XXXX µs ( XXXX x 62.5 ns periods) 
mwr -force 0xA0046008 0 
# Start transmitting and recording! 
mwr -force 0xA0047000 1 
# Delay before ending recording
after 1000
# Stop recording
mwr -force 0xA0047000 0 
puts "TX usage resumed"





