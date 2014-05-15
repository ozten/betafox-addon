
These notes analyze the d2g prototype's [phonetools](https://github.com/ozten/d2g/tree/master/phonetools) and [server scripts](https://github.com/ozten/d2g/tree/master/bin).

## Related
* [Installing Reviewer Certs](https://wiki.mozilla.org/Marketplace/Reviewers/Apps/InstallingReviewerCerts)
* [certutil](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS/Tools/certutil)

## Phonetools scripts

* configure-2-distribute-2-gecko.sh - provision phone
  Accepts a hostname, where we will fetch the .der certificate

  * new_certdb.sh - `certutil` is used to create a SQL database

  The certificate at hostname/cert is retrieved. This DER file is stored on disk.

  * add_or_replace_root_cert.sh - `certutil` used to delete existing version of this certificate from the db (may fail). `certutil` used to add this certificate to the certificate database.
  * find_device_name.sh - Using `adb devices` determine the FxOS device name (full_unagi, full_keon, etc)
  * push_certdb.sh - `adb` used to get profile directory name. Files in the new certificate database directory are pushed via `adb` into the users profile.
  * change_trusted_servers.sh - `adb` used to backup `/system/b2g/defaults/pref/user.js` to `user-old.js`. Everything except `dom.mozApps.signed_apps_installable_from` is copied to a new `user.js` file. `dom.mozApps.signed_apps_installable_from` is added set to our new trustable servers. The filesystem is re-mounted in read/write mode with `adb`. The `user.js` overwrites the existing file on the devices. The filesystem is re-mounted as read-only. The device is re-booted by `adb`.

### Other

* check_device.sh - Determines if a device has been provisioned
* pull_certdb.sh - Backs up certificate database from device

### Data
d2g-public-key.der
marketplace-dev-public-root.der
marketplace-dev-reviewers-root.der 	
marketplace-stage-public-root.der
root-ca-reviewers-marketplace.der
twoblanklines 	

## Server scripts

* generate_cert.sh - Given an output directory and a password file, uses `certutil` to generate a new certificate database. Uses `certutil` to generate a new signing certificate into this new databse. Uses `certutil` to output the trusted certificate in a DER file.
* sign_b2g_app.py - Given password file, uses `plc4`, `nspr4`, `nss3` and `smime3` to sign the packaged app. Outputs a signed app to the filesystem.

### Wrappers

* generate.sh - Calls `generate_cert.sh` and `sign_app.sh`
* sign_app.sh - Wrapper for `sign_b2g_app.py`
* nss_ctypes.py - Python wrapper for low level liberaries