ccis_protocol = Proto("CCIS",  "CCIS NEC Protocol")

message_length = ProtoField.int32("ccis.message_length", "messageLength", base.DEC)
from_ip = ProtoField.int32("ccis.from_ip","from_ip", base.DEC)
from_port = ProtoField.int32("ccis.from_port","from_port", base.DEC)
opcode_number = ProtoField.int32("ccis.message","message", base.DEC)

protocolName = ProtoField.string("ccis.protocolName","Protocol Name", base.NONE)
headerVersion = ProtoField.string("ccis.headerVersion","Header Version", base.NONE)
messageSequenceNumber = ProtoField.string("ccis.messageSequenceNumber","Message Sequence Number", base.NONE)
dataLengthOfLevel4Message = ProtoField.string("ccis.dataLengthOfLevel4Message","Data Length of Level-4 Message", base.NONE)
cmdNumber = ProtoField.string("ccis.cmdNumber","Command Number", base.NONE)
checksum = ProtoField.string("ccis.checksum","Checksum", base.NONE)
prisid = ProtoField.string("ccis.prisid","PRI/SID", base.NONE) 
cktNumber = ProtoField.string("ccis.cktNumber","Circuit Number", base.NONE)
dtcLength = ProtoField.string("ccis.dtcLength","Data Length", base.NONE)
level4HeaderDataLength = ProtoField.string("ccis.level4HeaderDataLength","Level-4 Header Data Length", base.NONE)
level4HeaderVersion = ProtoField.string("ccis.level4HeaderVersion","Level-4 Header Version", base.NONE)
ipVersion = ProtoField.string("ccis.ipVersion","ipVersion", base.NONE)

localSelfIpAddress = ProtoField.string("ccis.localSelfIpAddress","localSelfIpAddress", base.NONE)
localMateIpAddress = ProtoField.string("ccis.localMateIpAddress","localMateIpAddress", base.NONE)
selfVirtualCircuitNumber = ProtoField.string("ccis.selfVirtualCircuitNumber","selfVirtualCircuitNumber", base.NONE)
mateVirtualCircuitNumber = ProtoField.string("ccis.mateVirtualCircuitNumber","mateVirtualCircuitNumber", base.NONE)
selfVirtualCicNumber = ProtoField.string("ccis.selfVirtualCicNumber","selfVirtualCicNumber", base.NONE)
mateVirtualCicNumber = ProtoField.string("ccis.mateVirtualCicNumber","mateVirtualCicNumber", base.NONE)
selfPortNumber = ProtoField.string("ccis.selfPortNumber","selfPortNumber", base.NONE)
matePortNumber = ProtoField.string("ccis.matePortNumber","matePortNumber", base.NONE)


ccis_protocol.fields = {
	discriminator, message_length, from_ip, from_port, opcode_number,
	protocolName, headerVersion, messageSequenceNumber, dataLengthOfLevel4Message,
	cmdNumber,checksum,prisid,cktNumber,dtcLength,level4HeaderDataLength,
	level4HeaderVersion,ipVersion,
	localSelfIpAddress,localMateIpAddress,selfVirtualCircuitNumber,
	mateVirtualCircuitNumber,selfVirtualCicNumber,mateVirtualCicNumber,
	selfPortNumber,matePortNumber
	}

function ccis_protocol.dissector(buffer, pinfo, tree)
    length = buffer:len()
    if length == 0 then return end

    pinfo.cols.protocol = ccis_protocol.name
    local mainTree = tree:add(ccis_protocol, buffer(), "NEC CCIS Protocol Data")
    local ccisHeaderSubTree = mainTree:add("CCIS Header")
	ccisHeaderSubTree:add(protocolName, 				buffer(0,8))
	ccisHeaderSubTree:add(headerVersion, 				buffer(8,2),  buffer(8,2):uint()  .. " -- (0x"..buffer(8,2) .."h)")
	ccisHeaderSubTree:add(messageSequenceNumber, 		buffer(10,2), buffer(10,2):uint() .. " -- (0x"..buffer(10,2).."h)")
	ccisHeaderSubTree:add(dataLengthOfLevel4Message, 	buffer(12,2), buffer(12,2):uint() .. " -- (0x"..buffer(12,2).."h)")
	ccisHeaderSubTree:add(cmdNumber, 					buffer(14,1), buffer(14,1):uint() .. " -- (0x"..buffer(14,1).."h)")
	ccisHeaderSubTree:add(checksum, 					buffer(15,1), buffer(15,1):uint() .. " -- (0x"..buffer(15,1).."h)")
	ccisHeaderSubTree:add(prisid, 						buffer(16,1), buffer(16,1):uint() .. " -- (0x"..buffer(16,1).."h)")
	ccisHeaderSubTree:add(cktNumber, 					buffer(17,1), buffer(17,1):uint() .. " -- (0x"..buffer(17,1).."h)")
	ccisHeaderSubTree:add(dtcLength, 					buffer(18,2), buffer(18,2):uint() .. " -- (0x"..buffer(18,2).."h)")
	ccisHeaderSubTree:add(level4HeaderDataLength, 		buffer(20,2), buffer(20,2):uint() .. " -- (0x"..buffer(20,2).."h)")
	ccisHeaderSubTree:add(level4HeaderVersion, 			buffer(22,2), buffer(22,2):uint() .. " -- (0x"..buffer(22,2).."h)")
	ccisHeaderSubTree:add(ipVersion, 					buffer(24,2), buffer(24,1):uint() .. " -- (0x"..buffer(24,1).."h)")

	local from_ip = bytes_to_ip(buffer,26)
	local from_port = buffer(42,2):uint()
	local to_ip = bytes_to_ip(buffer,30)
	local to_port = buffer(44,2):uint()

	local connectionInfo = mainTree:add("Connection Info")
	connectionInfo:add(localSelfIpAddress, 		 buffer(26,4) , "From "..from_ip..":"..from_port)
	connectionInfo:add(localMateIpAddress, 		 buffer(30,4), "To "..to_ip..":"..to_port)
	connectionInfo:add(selfVirtualCircuitNumber, buffer(34,2), buffer(34,2):uint() .. " -- (0x"..buffer(34,2).."h)")
	connectionInfo:add(mateVirtualCircuitNumber, buffer(36,2), buffer(36,2):uint() .. " -- (0x"..buffer(36,2).."h)")
	connectionInfo:add(selfVirtualCicNumber, 	 buffer(38,2), buffer(38,2):uint() .. " -- (0x"..buffer(38,2).."h)")
	connectionInfo:add(mateVirtualCicNumber, 	 buffer(40,2), buffer(40,2):uint() .. " -- (0x"..buffer(40,2).."h)")
	connectionInfo:add(selfPortNumber, 			 buffer(42,2), buffer(42,2):uint() .. " -- (0x"..buffer(42,2).."h)")
	connectionInfo:add(matePortNumber, 			 buffer(44,2), buffer(44,2):uint() .. " -- (0x"..buffer(44,2).."h)")

	----ccisHeaderSubTree:add(message_length, buffer(11,2))
    if length>26 then
        local from_ip = bytes_to_ip(buffer,26)
	local from_port = buffer(42,2):uint()
	local FromSubtree = mainTree:add(ccis_protocol, buffer(), "From "..from_ip..":"..from_port)
        -- FromSubtree:add("IP " .. from_ip, buffer(26,4))
	-- FromSubtree:add("Port: " .. from_port, buffer(42,2))
	  
	  
	local to_ip = bytes_to_ip(buffer,30)
	local to_port = buffer(44,2):uint()
	local ToSubtree = mainTree:add(ccis_protocol, buffer(), "To "..to_ip..":"..to_port)
	-- ToSubtree:add("IP " .. to_ip, buffer(30,4))
	-- ToSubtree:add("Port: " .. to_port, buffer(44,2))
	  
	-- udp_ip_local = bytes_to_ip(buffer,48)
	-- udp_ip_remote = bytes_to_ip(buffer,62)
	-- mainTree:add_le("UDP IP Local: " .. udp_ip_local)
	-- mainTree:add_le("UDP IP Remote: " .. udp_ip_remote)
	local opcode_number = buffer(101,1):bytes():tohex()
	
    local opcode_name = get_opcode_name(opcode_number, buffer)
    pinfo.cols.info = opcode_name
	mainTree:add_le(opcode_number .. "--" .. opcode_name .. "")
	local opc = buffer(96,1)
	mainTree:add_le("OPC " .. opc)
	if opcode_name == "INVITE" then
	    local number_b_length = tonumber("0x"..(tostring(buffer(104,1)):sub(0,1)))
	    -- mainTree:add("Number B len: " .. number_b_length,buffer(104,1))
		  
            local bytes_to_read = math.floor((number_b_length+1)/2)
            -- mainTree:add("bytes_to_read: " .. bytes_to_read)
		  
            local number_b_reversed = buffer(105,bytes_to_read)
            local number_b = byte_reverse(number_b_reversed):sub(0,number_b_length)
            mainTree:add("Number B: " .. number_b,buffer(105,bytes_to_read))
		  
            local number_a_reversed = buffer(109+bytes_to_read,2)
            local number_a = (byte_reverse(number_a_reversed)):gsub("a", "0")
            mainTree:add("Number A: " .. number_a)
        end
    end
    --mainTree:add(ip_address,buffer(159,4))
end

function byte_reverse(reversed)
    local result=""
	local rev_string = tostring(reversed)
	for i = 1, rev_string:len(), 2 do
            result = result .. rev_string:sub(i+1,i+1) .. rev_string:sub(i,i)
	end
    return result
end

function bytes_to_ip(buffer,start)
    local oct_1 = buffer(start,1):le_uint()
    local oct_2 = buffer(start+1,1):le_uint()
    local oct_3 = buffer(start+2,1):le_uint()
    local oct_4 = buffer(start+3,1):le_uint()
    local ip = oct_1 .. "." .. oct_2 .. "." .. oct_3 .. "." .. oct_4
    return ip
end

function get_opcode_name(opcode, buffer)
    local opcode_name = "Unknown"

    if opcode == "8E" then opcode_name = "8e-O/G Queuing cancel "
    elseif opcode == "65" then opcode_name = "65-Subscriber busy  "
    elseif opcode == "14" then opcode_name = "14-Address complete "
    elseif opcode == "17" then opcode_name = "17-Release guard  "
    elseif opcode == "27" then opcode_name = "27-Service set "
    elseif opcode == "2F" then opcode_name = "2f-Answer with information "
    elseif opcode == "3F" then opcode_name = "3f-Service set "
	elseif opcode == "21" then opcode_name = "21-INVITE-Initial address with additional information"
    elseif opcode == "46" then opcode_name = "46-Clear forward"
    elseif opcode == "36" then opcode_name = "46-Clear back"
	end
	
    return opcode_name
end


local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(57000, ccis_protocol)
--local udp_port = DissectorTable.get("udp.port")
--udp_port:add(56000, ccis_protocol)
