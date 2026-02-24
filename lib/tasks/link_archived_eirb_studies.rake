task link_archived_eirb_studies: :environment do
  associations = {
    1135 => "Pro00025910",
    1133 => "Pro00026432",
    1074 => "Pro00027311",
    567  => "Pro00027370",
    1088 => "Pro00027552",
    685  => "Pro00035838",
    1164 => "Pro00036741",
    1207 => "Pro00037576",
    1049 => "Pro00039639",
    1206 => "Pro00040583",
    167  => "Pro00041208",
    687  => "Pro00041511",
    2176 => "Pro00042341",
    884  => "Pro00042470",
    1076 => "Pro00042727",
    1032 => "Pro00046334",
    1170 => "Pro00049108",
    744  => "Pro00049313",
    688  => "Pro00050536",
    696  => "Pro00050830",
    821  => "Pro00050882",
    694  => "Pro00051394",
    1191 => "Pro00051462",
    818  => "Pro00053030",
    1194 => "Pro00053591",
    1116 => "Pro00053650",
    1665 => "Pro00055137",
    819  => "Pro00055984",
    1142 => "Pro00057146",
    823  => "Pro00057542",
    55   => "Pro00058485",
    1055 => "Pro00059438",
    1198 => "Pro00059681",
    70   => "Pro00061543",
    56   => "Pro00062311",
    41   => "Pro00063206",
    52   => "Pro00063987",
    49   => "Pro00064191",
    61   => "Pro00064246",
    242  => "Pro00065249",
    188  => "Pro00066392",
    440  => "Pro00066509",
    399  => "Pro00067011",
    580  => "Pro00068776",
    678  => "Pro00069586",
    717  => "Pro00070598",
    681  => "Pro00070752",
    1230 => "Pro00071483"
  }

  puts "Linking #{associations.count} archived studies..."

  linked_count = 0
  error_count = 0

  associations.each do |rmid, eirb_id|
    rm = ResearchMaster.find_by(id: rmid)
    protocol = Protocol.find_by(eirb_id: eirb_id)

    unless rm
      puts "#{rmid} rmid not found"
      error_count += 1
      next
    end

    unless protocol
      puts "#{eirb_id} protocol with eirb_id #{eirb_id} not found"
      error_count += 1
      next
    end

    rm.assign_attributes(
      eirb_protocol_id: protocol.id,
      eirb_validated: true,
      eirb_association_date: Date.new(2025, 7, 30),
      eirb_original_association_date: rm.eirb_original_association_date || Date.new(2025, 7, 30)
    )

    if rm.save(validate: false)
      linked_count += 1
    else
      puts "Error linking RMID #{rmid} to EIRB ID #{eirb_id}: #{rm.errors.full_messages.join(', ')}"
      error_count += 1
    end
  end
  puts "\nExpected link count: #{associations.count} \nActual link count: #{linked_count} \nError count: #{error_count}"
end
