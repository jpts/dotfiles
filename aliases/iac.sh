alias terraform-clean-all="terraform state list | tr '\n' '\0' | xargs -0 terraform state rm"
