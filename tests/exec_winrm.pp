import 'data.pp'

transport { 'winrm':
  server   => $data['server'],
  username => $data['username'],
  password => $data['password'],
}

exec { 'Set-ExecutionPolicy Unrestricted':
  unless    => '$result = (Get-ExecutionPolicy); $result -eq "Unrestricted"',
  logoutput => on_failure,
  provider  => 'winrm',
  transport => Transport['winrm'],
}
