Facter.add('cluster') do
  setcode do
    Facter.value(:fqdn).split('-').first
  end 
end
