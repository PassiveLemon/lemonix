let
  # Normal users should have a passphrase
  # ssh-keygen

  # Get this from /etc/ssh/ssh_host_ed25519_key.pub (services.openssh.hostKeys)
  aluminum = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB/5WTbUE/YjK0EqTLGJwlE4/qA5EJB8Ey/w2o09FGtV";
  palladium = "";
  silver = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbedW5DDGCzGpbym2f0Ex+efnyfzFfHRPAhDFY9ZI5K";

  borg = {
    silver = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOH57JnHLmW6Al34ksW1zb0TJq7IY9mZLN7kBiFR0dYi";
  };
  lemon = {
    aluminum = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXRE/wC3EAMvJiRIpWv/Rl1+UfwmxF0p8M+YpUkelmU";
    silver = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHteP0JhNBJOlom+X8PY8s0FXPdUY4VcV6PgPPzXIKi";
  };
in
{
  # agenix -e <file>
  # First list are hosts and second are users
  "borgBackupPass.age".publicKeys = [ palladium silver ] ++ [ borg.silver lemon.silver ];
  "tailscaleAuthKey.age".publicKeys = [ aluminum silver ] ++ [ lemon.silver ];
}

