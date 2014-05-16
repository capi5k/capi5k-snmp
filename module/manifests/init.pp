class snmp {

  $miburl = hiera("snmp::miburl", "")
  $oidurl = hiera("snmp::oidurl", "")
  $mib = hiera("snmp::mib", "")
  $oid = hiera("snmp::oid", "")

  package { 'snmp':
    ensure => present
  }

  package { 'snmp-mibs-downloader': 
    ensure => present
  }

  file { 'snmpdirectory':
    ensure => directory,
    path   => "/usr/share/snmp/mibs"
  }
 
  #todo add onlyif
  exec { 'mibs':
    command => "wget -q ${miburl} -O ${mib}",
    path    => ["/usr/bin"],
    creates => "/usr/share/snmp/mibs/${mib}",
    cwd     => "/usr/share/snmp/mibs"
  }

  exec { 'oid':
    command => "wget -q ${oidurl} -O ${oid}",
    path    => ["/usr/bin"],
    creates => "/usr/share/snmp/mibs/${oid}",
    cwd     => "/usr/share/snmp/mibs",
   }

  exec { 'snmp.conf':
    command => "echo mibs ${mib} >> /etc/snmp/snmp.conf",
    path    => ["/usr/bin", "/bin"],
    require => [Package["snmp"], Package["snmp-mibs-downloader"]]
  }
}
