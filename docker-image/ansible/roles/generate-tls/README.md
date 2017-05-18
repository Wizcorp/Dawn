# generate-tls

Uses vault to generate TLS certificates and store them on the target machine.

## Variables

* `pki`
	* `backend`: The backend to use
	* `role`: The role to use on that backend
	* `[owner]`: The owner of the files
	* `[group]`: The group that owns the files
	* `files`
		* `cert`: Where to store the certificate
		* `key`: Where to store the private key
		* `ca`: Where to store the CA file
	* `request_data`: The request data to pass to vault, as an object
	* `[notify]`: Notify handlers
	* `[delegate_to]`: Delegate writing the certificates to another node