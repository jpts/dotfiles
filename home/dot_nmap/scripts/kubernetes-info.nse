local shortport =  require "shortport"
local json = require "json"
local http = require "http"
local nmap = require "nmap"
local sslcert = require "sslcert"
local stringaux = require "stringaux"
local stdnse = require "stdnse"
local tableaux = require "tableaux"

description = [[Detects the Kubernetes API Server version.]]

---
-- @output
-- PORT    STATE SERVICE
-- 443/tcp open  kubernetes
-- | kubernetes-info:
-- |   Certificate CommonName: kube-apiserver
-- |   Certificate SubjectAltNames:
-- | 	zzz.zz4.eu-west-1.eks.amazonaws.com
-- | 	ip-10-0-1-101.eu-west-1.compute.internal
-- | 	10.100.0.1
-- | 	192.168.101.16
-- | 	10.0.1.101
-- |   gitTreeState: clean
-- |   minor: 20+
-- |   goVersion: go1.15.12
-- |   compiler: gc
-- |   buildDate: 2021-07-31T00:29:12Z
-- |   major: 1
-- |   platform: linux/amd64
-- |   gitCommit: d886092805d5cc3a47ed5cf0c43de38ce442dfcb
-- |_  gitVersion: v1.20.7-eks-d88609


author = "James Cleverley-Prance @jpts_"
license = "MIT"
categories = {"discovery", "safe"}

function table.removeValue(tab, value)
    for i, v in ipairs(tab) do
        if v == value then
            table.remove(tab, i)
            break
        end
    end
end

portrule = shortport.port_or_service({443,6443,8443}, {"ssl", "https"})

action = function(host, port)
  local status, cert = sslcert.getCertificate(host, port)
  local lines = {}
  if cert.extensions then
    for _, e in ipairs(cert.extensions) do
      if e.name == "X509v3 Subject Alternative Name" then
        for _,v in ipairs(stringaux.strsplit(", ", e.value)) do
            stdnse.debug(1, "Got SAN "..v)
            lines[#lines + 1] = stringaux.strsplit(":", v)[2]
        end
        break
      end
    end
  end

  local response = {}
  if tableaux.contains(lines, "kubernetes") then
    table.removeValue(lines, "localhost")
    table.removeValue(lines, "kubernetes")
    table.removeValue(lines, "kubernetes.default")
    table.removeValue(lines, "kubernetes.default.svc")
    table.removeValue(lines, "kubernetes.default.svc.cluster.local")

    port.version.name = 'kubernetes'
    port.version.product = "Kubernetes"
    nmap.set_port_version(host, port)
    response[#response + 1] = "Certificate CommonName: "..cert.subject["commonName"]
    response[#response + 1] = "Certificate SubjectAltNames:\n\t"..table.concat(lines, "\n\t")
  end

  url = "https://"..host.ip..":"..port.number.."/version"
  local http_response = http.get_url(url)

  if http_response and http_response.status and
    http_response.status == 200 and http_response.body then

    ok_json, response["Version Info"] = json.parse(http_response.body)
    port.version.version = response["gitVersion"]
  else
    stdnse.debug(1, "Unable to GET "..url)
  end

  url = "https://"..host.ip..":"..port.number.."/api/v1/namespaces/kube-public/configmaps/cluster-info"
  local http_response = http.get_url(url)

  if http_response and http_response.status and
    http_response.status == 200 and http_response.body then

    response["Kubeadm Cluster"] = "true"
  else
    response["Kubeadm Cluster"] = "false"
  end

  return response
end
