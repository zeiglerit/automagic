resource "aws_s3_bucket" "txtn_logs" {
    buckets = "fintech-txtn-logs-${random_id.suffix.hex}"

    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }

    version {
        enabled = true 
    }
}

resource "random_id" "suffix" {
    byte_length = 4
}
