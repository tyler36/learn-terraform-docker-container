# Terraform test to verify nginx container port exposure
# This test confirms that nginx is properly exposed on port 8000

run "setup" {
  command = apply
}

run "verify_nginx_port_8000" {
  command = plan

  # Test 1: Verify external port is 8000
  assert {
    condition     = docker_container.nginx.ports[0].external == 8000
    error_message = "Nginxコンテナは外部ポート8000を公開する必要があります"
  }

  # Test 2: Verify internal port is 80 (nginx default)
  assert {
    condition     = docker_container.nginx.ports[0].internal == 80
    error_message = "Nginxコンテナの内部ポートは80である必要があります"
  }

  # Test 3: Verify container start setting
  assert {
    condition     = docker_container.nginx.start == true
    error_message = "Nginxコンテナは起動するように設定されている必要があります"
  }

  # Test 4: Verify only one port mapping exists
  assert {
    condition     = length(docker_container.nginx.ports) == 1
    error_message = "Nginxコンテナは正確に1つのポートマッピングを持つ必要があります"
  }

  # Test 5: Verify container name matches variable
  assert {
    condition     = docker_container.nginx.name == var.container_name
    error_message = "コンテナ名はcontainer_name変数と一致する必要があります"
  }
}

run "verify_after_apply" {
  command = apply

  # Test that everything is actually applied correctly
  assert {
    condition = alltrue([
      docker_container.nginx.ports[0].external == 8000,
      docker_container.nginx.ports[0].internal == 80,
      docker_container.nginx.start == true
    ])
    error_message = "適用後、nginxはポート80から8000へのマッピングで設定され、起動するように設定されている必要があります"
  }
}
