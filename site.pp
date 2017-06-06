node default {
  file {'/tmp/it_works.txt':
    ensure => 'present',
  }
}
