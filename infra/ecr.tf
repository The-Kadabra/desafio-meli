resource "aws_ecr_repository" "desafio_meli_app" {
  name                 = "desafio-meli-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Política de lifecycle para manter apenas a latest
resource "aws_ecr_lifecycle_policy" "desafio_meli_app" {
  repository = aws_ecr_repository.desafio_meli_app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only latest image"
        selection    = {
          tagStatus      = "tagged"
          tagPrefixList  = ["latest"]
          countType      = "imageCountMoreThan"
          countNumber    = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Remove untagged images"
        selection    = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = 1  # não pode ser zero
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

output "repository_url" {
  value = aws_ecr_repository.desafio_meli_app.repository_url
}

resource "null_resource" "push_image" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --region us-east-1 \
      | docker login --username AWS --password-stdin 505838347528.dkr.ecr.us-east-1.amazonaws.com
      docker build -t desafio-meli-app:latest -f ../app/Dockerfile ../app
      docker tag desafio-meli-app:latest 505838347528.dkr.ecr.us-east-1.amazonaws.com/desafio-meli-app:latest
      docker push 505838347528.dkr.ecr.us-east-1.amazonaws.com/desafio-meli-app:latest
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
    # Garante que o recurso seja recriado se algum arquivo crítico mudar
    dockerfile = filesha256("../app/Dockerfile")
    package    = filesha256("../app/package.json")
    index_js   = filesha256("../app/src/index.mjs")
  }
}
