data "http" "home_ip" {
  url = "https://checkip.amazonaws.com/"
}

locals {
  home_cidr = "${trimspace(data.http.home_ip.response_body)}/32"
}

output "the_home_cidr" {
  value = local.home_cidr
}

