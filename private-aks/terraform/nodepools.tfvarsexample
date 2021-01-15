additional_node_pools  = [
    {
      name               = "pool2"
      vm_size            = "Standard_F2s_v2"
      node_count         = 1
      mode               = "User"
      availability_zones = ["1", "2", "3"]
      os_type            = "Linux"
      priority           = "Regular"
      subnet_prefix        =  ["10.0.17.0/24"]
      tags = {
        source = "terraform"
      }
       node_labels = {
        source = "terraform"
      }
    },
    {
      name               = "pool3"
      vm_size            = "Standard_F2s_v2"
      node_count         = 3
      mode               = "User"
      availability_zones = ["1", "2", "3"]
      os_type            = "Linux"
      priority           = "Regular"
      subnet_prefix        =  ["10.0.18.0/24"]
      tags = {
        source = "terraform"
        use    = "application"
      }
       node_labels = {
        source = "terraform"
      }
    }
  ]
