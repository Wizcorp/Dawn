# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
    capabilities = ["update"]
}

# Allow the token to create a new docker client cert
path "docker/pki/issue/client.dawn" {
    policy = "write"
    capabilities = ["create"]
}
