resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_prefix}-bucket-${var.bucket_suffix}"
}

# Habilitar el versionado
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configuración de acceso público (Paso 1: Quitar bloqueos)
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Política de solo lectura pública (Paso 2)
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.this.arn}/*"
      },
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.public_access]
}
