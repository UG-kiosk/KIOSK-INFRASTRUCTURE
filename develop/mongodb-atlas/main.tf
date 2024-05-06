module "shared_envs_dev" {
  source = "../../shared-envs/development"
}

data "azurerm_key_vault_secret" "mongodbatlas_organization_id" {
  name         = var.mongodbatlas_organization_id_secret_name
  key_vault_id = data.terraform_remote_state.ug_kiosk_key_vault_state.outputs.key_vault_id
}

resource "mongodbatlas_team" "ug_kiosk_team_devs" {
  org_id     = data.azurerm_key_vault_secret.mongodbatlas_organization_id.value
  name       = var.ug_kiosk_team_name
  usernames  = [
    "ola10417@gmail.com",
    "oskar.kusmierekk@gmail.com",
    "zapiorkowski.j@gmail.com",
    "k.sokolowski.807@studms.ug.edu.pl",
    "towarnickaj@gmail.com"
    ]
}

resource "mongodbatlas_project" "ug_kiosk_atlas_project" {
  name = var.mongodbatlas_project_name
  org_id = data.azurerm_key_vault_secret.mongodbatlas_organization_id.value

  teams {
    team_id = mongodbatlas_team.ug_kiosk_team_devs.team_id
    role_names = [
      "GROUP_OWNER",
      "GROUP_STREAM_PROCESSING_OWNER",
      "GROUP_CLUSTER_MANAGER",
      "GROUP_DATA_ACCESS_ADMIN",
      "GROUP_DATA_ACCESS_READ_WRITE",
      "GROUP_DATA_ACCESS_READ_ONLY",
      "GROUP_READ_ONLY",
      "GROUP_SEARCH_INDEX_EDITOR"
    ]
  }
}

resource "mongodbatlas_advanced_cluster" "kiosk_api_cluster" {
  project_id   = mongodbatlas_project.ug_kiosk_atlas_project.id
  name         = var.kiosk_api_cluster_name
  cluster_type = var.cluster_type

  replication_specs {
    region_configs {
      electable_specs {
        instance_size = var.cluster_instance_size
        node_count    = 1
      }

      auto_scaling {
        disk_gb_enabled = false
        compute_enabled = false
      }
      
      provider_name         = var.provider_name
      backing_provider_name = var.backing_provider_name
      priority              = 7
      region_name           = var.region_name
    }
  }
}
