task update_pi_department: :environment do
  sparc_api = ENV.fetch('SPARC_API')

  puts("\nBeginning data retrieval from SPARC API...")

  def progress_bar(count, increment)
    bar = "Progress: "
    bar += "=" * (count/increment)
    bar += "#{count/increment}0%\r"
  end

  protocols = HTTParty.get(
    "#{sparc_api}/protocols",
    timeout: 500,
    headers: { 'Content-Type' => 'application/json' }
  )
  puts "Done"

  puts "Beginning department data update"
  count = 0
  updated_pis = []

  protocols.each do |protocol|
    protocol_to_update = Protocol.find_by(sparc_id: protocol['id'])
    pi = protocol_to_update.primary_pi
    unless Department.exists?(name: protocol['pi_department'].humanize.titleize)
      sparc_department = Department.create(name: protocol['pi_department'].humanize.titleize)
    else
      sparc_department = Department.find_by(name: protocol['pi_department'].humanize.titleize)
    end
    if pi
      pi.update_attribute(:department_id, sparc_department.id)
      updated_pis.append(pi.id) if pi.save
    end
    print(progress_bar(count, protocols.count/10)) if count % (protocols.count/10)
    count += 1
  end
  puts("")
  puts("Done!")
  puts("Updated primary pis total: #{updated_pis.count}")
  puts("Finished SPARC_API data import.")

  puts "Fixing association for PIs that do not belong to a department..."
  pis_to_fix = PrimaryPi.where(department_id: nil)

  pis_to_fix.each do |pi|
    na_department = Department.find_by(name: 'N/A')
    pi.update_attribute(:department_id, na_department.id)
  end

  puts "Associations fixed. Task complete"
end
