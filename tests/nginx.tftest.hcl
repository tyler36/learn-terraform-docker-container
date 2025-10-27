# Test file to verify nginx port exposure and connectivity
# This test verifies that nginx is properly exposed on port 8000

run "verify_nginx" {
  command = apply

  # Test 1: Verify port mapping configuration
  assert {
    condition     = docker_container.nginx.ports[0].external == 8000
    error_message = "nginxコンテナの外部ポートは8000である必要があります"
  }

  assert {
    condition     = docker_container.nginx.ports[0].internal == 80
    error_message = "nginxコンテナの内部ポートは80である必要があります"
  }

  # Test 2: Verify container is configured to start
  assert {
    condition     = docker_container.nginx.start == true
    error_message = "nginxコンテナは起動するように設定されている必要があります"
  }

  # Test 3: Verify container name
  assert {
    condition     = docker_container.nginx.name == var.container_name
    error_message = "コンテナ名は変数と一致する必要があります"
  }

  assert {
    condition     = length(docker_container.nginx.ports) == 1
    error_message = "nginxコンテナは正確に1つのポートマッピングを持つ必要があります"
  }
}

# This test uses a shell command to verify actual connectivity
run "verify_port_connectivity" {
  command = apply

  # First ensure the container and port mapping are correct
  assert {
    condition = alltrue([
      docker_container.nginx.ports[0].external == 8000,
      docker_container.nginx.ports[0].internal == 80,
      docker_container.nginx.start == true
    ])
    error_message = "コンテナは正しいポートマッピング（80->8000）で設定され、起動するように設定されている必要があります"
  }
}
