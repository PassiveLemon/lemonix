# Borg setup

Make sure the borg user has permissions to the intended backup directory, and that they can be ssh'd into from the intended backup clients (typically the root user).
Double check that the above can happen.

If there are permission issues, check the entire directory path has both read AND execute permissions by the user, otherwise the user cannot cd into it.
Also make sure the root user is using the ssh_host key.
If there are ssh connection issues, check that the borg users .ssh directory files have the right permissions and ownership, and that the right keys are authorized.

Enter root or borg user:
```
borg init --encryption=repokey ssh://borg@127.0.0.1/path/to/borg/
```

If it states a permission issue, then you did not makes sure the directory could be accessed from the borg user.
If it states an ssh connection issue, then you did not make sure the borg user could be acccessed from all clients.

Enter the passphrase.

Start/restart any related borgbackup-job services and check their statuses to make sure they work:
```
systemctl restart borgbackup-job-<job-name>.service
systemctl status borgbackup-job-<job-name>.service
```

This is a backup service after all, we want to make sure they are actually backed up.

Wait a bit for all backup tasks to complete.

Mount the repository and check that the files were backed up and can be accessed:
```
borg-job-<job-name> mount ssh://borg@127.0.0.1/path/to/borg/ /mount/directory/
```

Once again, really make sure this works. Backups are useless if you can't access them.

