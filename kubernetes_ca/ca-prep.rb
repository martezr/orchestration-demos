require 'vault'

Vault.address = "http://vault:8200"
Vault.token   = "myroot"
mounts = Vault.sys.mounts
mount_points = []
mounts.each do |mount|
  mount_points.push(mount[0])
end
ca_cert = Vault.logical.write("pki/root/generate/internal", "common_name": "exampl11e.com", "ttl": "87600h")
puts ca_cert.data[:certificate]

int_ca_cert_csr = Vault.logical.write("pki_int/intermediate/generate/internal", "common_name": "exampl11e.com", "ttl": "43800h")
puts int_ca_cert_csr

#Vault.sys.mount("pki", "pki", "Root CA")
#Vault.sys.mount_tune("pki", max_lease_ttl: '87600h')

# Create Intermediate CA
#Vault.sys.mount("pki_int", "pki", "Root CA")
#Vault.sys.mount_tune("pki_int", max_lease_ttl: '87600h')
