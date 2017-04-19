resource "null_resource" "dawn" {
  depends_on = [
    "aws_instance.edge",
    "aws_instance.control",
    "aws_instance.worker",
    "aws_instance.storage"
  ]

  provisioner "local-exec" {
    command = "/dawn/scripts/gen_inventory.py > inventory"
  }
}