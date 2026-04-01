module "components" {
    for_each = var.component
    source = "git::https://github.com/MamidalaHemanChandra/terraform-aws-roboshop-component.git"
    component = each.key
    priority = each.value.priority
}