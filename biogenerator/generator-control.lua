local modem = peripheral.wrap("back")
modem.open(7)

while true do
   local event, modemSide, senderChannel, replyChannel, message, distance = os.pullEvent("modem_message")
   
   write("Received: " + message + "\n")
   
   if message == "enable" then
     rs.setBundledOutput("right", 0)
   else
     rs.setBundledOutput("right", colors.white)
   end
   
   sleep(0.1)
end
