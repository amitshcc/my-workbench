variable "instance_count_prv" {
  description = "Number of instances needed in private subnet"
  type        = number
  default     = 1
}

variable "instance_count_pub" {
  description = "Number of instances needed in public subnet"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "Size of Instance"
  type        = string
  default     = "t3.micro"
}

variable "my_ip" {
  description = "allow ssh from this IP range"
  type        = string
  default     = "110.227.157.244/32"
}

variable "my-ssh-key" {
  description = "SSH key to allow access to public instance"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCncvfKfkMskxoWpUArbh8b25QHyzj9+PZbVUm8z2p8D2MM+NsETjVsmN/qR6DQ0qWsfNJX9Zp1JwRHlfGQ7B5CeoXiplCR6yF724VNBUyc0fScDhLv3vwkgZ+KSMbS+Vi5OkDQyintUosKmfbEb+jaycHVXO6IcnFqmqx1uacm4jQlmvp5w1jXnNcIAuul97p8/70xRVpurpvHdXz2UgfHM3Iq1WTg4SXaHyrtXOZF0wo2ddD+mTmNG92Vu8HyiBYxZwgHbWbO3tjkzZ/eH5dsQNMfPUx0cf41kmtuG5GYMDgc8SGGOCstL9CIFQM/sOv2oUVZuA+HcDstGk6iKSY9AcABDEo+qvSMceYt4xo2md8C5iMNPo5CFXYDVMu6Kq9vrpf/kwMAAa+7uN0pXJnEFBun06DxS/f2cDcH/y6qY9PoRIX5jSTM7re0cxjpjhcmGhYgXwO1tCQQ68bVLgqAa8gPS13h1lgUiYbUIk1yjGwEXbd73P8wa3VrfKMyms= amitsharma@Amit-Sharma.local"
}
