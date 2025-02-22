let
  # Normal users should have a passphrase
  # ssh-keygen
  aluminum = "AAAAC3NzaC1lZDI1NTE5AAAAILU/6QN9j6jXztUj2JldcU9oW0T3BRuQ7Il4Mx5pC7Ko";
  palladium = "";
  silver = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbedW5DDGCzGpbym2f0Ex+efnyfzFfHRPAhDFY9ZI5K";

  borg = {
    silver = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOH57JnHLmW6Al34ksW1zb0TJq7IY9mZLN7kBiFR0dYi";
  };
  lemon = {
    silver = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHteP0JhNBJOlom+X8PY8s0FXPdUY4VcV6PgPPzXIKi";
  };
in
{
  # agenix -e <file>
  # First list are hosts and second are users
  "borgBackupPass.age".publicKeys = [ palladium silver ] ++ [ borg.silver lemon.silver ];
  "tailscaleAuthKey.age".publicKeys = [ aluminum silver ] ++ [ lemon.silver ];
}

