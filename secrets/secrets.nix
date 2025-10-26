let
  # Normal users should have a passphrase
  # ssh-keygen

  # Get this from /etc/ssh/ssh_host_ed25519_key.pub (services.openssh.hostKeys)
  # Make sure the root user is also using these keys
  aluminum = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB/5WTbUE/YjK0EqTLGJwlE4/qA5EJB8Ey/w2o09FGtV";
  silver = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbedW5DDGCzGpbym2f0Ex+efnyfzFfHRPAhDFY9ZI5K";
  titanium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCBA9bX/zAfV04lQXGPPL+f24qD+MrX7zDt+odiE0pI";

  borg = {
    silver = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOH57JnHLmW6Al34ksW1zb0TJq7IY9mZLN7kBiFR0dYi";
    titanium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGt7EoDxKbFzXMXVV+RF422Tt9dBS7gKIgWMLxWncax9";
  };
  lemon = {
    aluminum = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXRE/wC3EAMvJiRIpWv/Rl1+UfwmxF0p8M+YpUkelmU";
    silver = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHteP0JhNBJOlom+X8PY8s0FXPdUY4VcV6PgPPzXIKi";
    titanium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINxpX0Uf3Bf1lSSCxvX+oTRsHD1tkBPWYzYFjSRqZ/MK";
  };
in
{
  # agenix -e <file>
  # First list are hosts and second are users
  "borgBackupPass.age".publicKeys = [ silver titanium ] ++ [ borg.silver lemon.silver borg.titanium lemon.titanium ];
  "discordWebhook.age".publicKeys = [ titanium ] ++ [ lemon.titanium ];
  "tailscaleAuthKey.age".publicKeys = [ aluminum silver titanium ] ++ [ lemon.aluminum lemon.silver lemon.titanium ];
}

